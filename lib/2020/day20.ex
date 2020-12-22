defmodule Aoc202020 do
  @tile_size 10

  def parse_tile(tile) do
    [tile_id_line | tile_lines] = String.split(tile, "\n", trim: true)
    [_match, tile_id_str] = Regex.run(~r/Tile (\d+):/, tile_id_line)
    tile_id = String.to_integer(tile_id_str)

    tile_map =
      tile_lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y_index}, acc ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {col, x_index}, xacc ->
          Map.put(xacc, {x_index, y_index}, col)
        end)
      end)

    tile_array =
      tile_lines
      |> Enum.reduce([], fn row, acc ->
        acc ++ [String.split(row, "", trim: true)]
      end)

    {tile_id, tile_map, tile_array}
  end

  def rotate_tile(tile) do
    tile
    |> Enum.reverse()
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list(&1))
  end

  def flip_tile(tile) do
    tile |> Enum.map(&Enum.reverse(&1))
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(%{}, fn unparsed_tile, acc ->
      {tile_id, tile_map, tile_array} = parse_tile(unparsed_tile)
      Map.put(acc, tile_id, {tile_map, tile_array})
    end)
  end

  def find_edges(tile) do
    max_index = @tile_size - 1

    Enum.reduce(0..3, [], fn edge_num, acc ->
      edge =
        edge_num
        |> case do
          # left
          0 ->
            Enum.map(0..max_index, fn y ->
              Map.get(tile, {0, y})
            end)

          # top
          1 ->
            Enum.map(0..max_index, fn x ->
              Map.get(tile, {x, 0})
            end)

          # right
          2 ->
            Enum.map(0..max_index, fn y ->
              Map.get(tile, {max_index, y})
            end)

          # bottom
          3 ->
            Enum.map(0..max_index, fn x ->
              Map.get(tile, {x, max_index})
            end)
        end
        |> Enum.join("")

      acc ++ [edge]
    end)
  end

  def count_matches(tile, id, edges_for_tiles) do
    Enum.reduce(tile, [], fn str, acc ->
      str_rev = String.reverse(str)

      matches =
        Enum.reduce(edges_for_tiles, 0, fn {edge_tile_id, edge_list}, edgeacc ->
          if edge_tile_id == id do
            edgeacc
          else
            Enum.reduce(edge_list, edgeacc, fn edge, count_acc ->
              if edge == str || edge == str_rev, do: count_acc + 1, else: count_acc
            end)
          end
        end)

      acc ++ [matches]
    end)
  end

  def part1(tiles) do
    edges = Enum.map(tiles, fn {id, {tile, _array}} -> {id, find_edges(tile)} end)

    Enum.map(edges, fn {id, tile} ->
      {id,
       count_matches(tile, id, edges)
       |> Enum.frequencies()}
    end)
    |> Enum.filter(fn {_id, freqs} ->
      freqs[0] == 2
    end)
    |> Enum.reduce(1, fn {id, _freq}, acc -> id * acc end)
  end

  def find_matches(tile, id, edges_for_tiles) do
    tile
    |> Enum.with_index()
    |> Enum.reduce([], fn {str, main_index}, acc ->
      str_rev = String.reverse(str)

      matches =
        Enum.reduce_while(edges_for_tiles, nil, fn {edge_tile_id, edge_list}, _acc ->
          if edge_tile_id == id do
            {:cont, nil}
          else
            edge_list
            |> Enum.reduce_while(nil, fn edge, _acc ->
              edge
              |> case do
                edg when str == edg or str_rev == edg ->
                  {:halt, {edge_tile_id, main_index}}

                _ ->
                  {:cont, nil}
              end
            end)
            |> case do
              nil -> {:cont, nil}
              found -> {:halt, found}
            end
          end
        end)

      acc ++ [matches]
    end)
  end

  def translate_edge(0), do: :left
  def translate_edge(1), do: :top
  def translate_edge(2), do: :right
  def translate_edge(3), do: :bottom

  # Already rotated
  def rotate_edges(%{left: left, top: top, right: right, bottom: bottom} = current) do
    current
    |> Map.put(:top, left)
    |> Map.put(:right, top)
    |> Map.put(:bottom, right)
    |> Map.put(:left, bottom)
    |> Map.put(:pixels, rotate_tile(Map.get(current, :pixels)))
  end

  def flip_edges(%{left: left, right: right} = current) do
    current
    |> Map.put(:right, left)
    |> Map.put(:left, right)
    |> Map.put(:pixels, flip_tile(Map.get(current, :pixels)))
  end

  def determine_order([], _tile_map, visited), do: visited

  def determine_order([first_id | queue], tile_map, visited) do
    direction_keys = [:left, :top, :right, :bottom]

    next_steps =
      Map.get(tile_map, first_id)
      |> Enum.filter(fn {key, _x} -> key in direction_keys end)
      |> Enum.reject(fn {_key, x} -> is_nil(x) end)
      |> Enum.map(fn {_key, id} ->
        id
      end)
      |> Enum.reject(fn x -> x in visited end)
      |> Enum.reject(fn x -> x in queue end)

    determine_order(queue ++ next_steps, tile_map, visited ++ [first_id])
  end

  def connected_edge(:left), do: :right
  def connected_edge(:top), do: :bottom
  def connected_edge(:right), do: :left
  def connected_edge(:bottom), do: :top

  def edge_matches?(%{pixels: parent_tile}, parent_side, %{pixels: current_tile}) do
    current_edge = connected_edge(parent_side)

    0..(@tile_size - 1)
    |> Enum.reduce_while(true, fn index, acc ->
      current_edge
      |> case do
        :left ->
          Enum.at(Enum.at(parent_tile, index), 9) == Enum.at(Enum.at(current_tile, index), 0)

        :right ->
          Enum.at(Enum.at(parent_tile, index), 0) == Enum.at(Enum.at(current_tile, index), 9)

        :top ->
          Enum.at(Enum.at(parent_tile, 9), index) == Enum.at(Enum.at(current_tile, 0), index)

        :bottom ->
          Enum.at(Enum.at(parent_tile, 0), index) == Enum.at(Enum.at(current_tile, 9), index)
      end
      |> if do
        {:cont, acc}
      else
        {:halt, false}
      end
    end)
  end

  def determine_rotations(tile_map, tiles) do
    direction_keys = [:left, :top, :right, :bottom]

    first_id =
      tile_map
      |> Map.keys()
      |> List.first()

    tile_ids = determine_order([first_id], tile_map, [])

    tile_ids
    |> Enum.reduce(tile_map, fn tile_id, acc ->
      {_, pixels} = Map.get(tiles, tile_id)

      tile =
        acc[tile_id]
        |> Map.put_new(:pixels, pixels)

      Enum.reduce(direction_keys, acc, fn dkey, new_acc ->
        Map.get(tile, dkey)
        |> case do
          nil ->
            new_acc

          match_id ->
            {_, subpixels} = Map.get(tiles, match_id)

            current =
              Map.get(new_acc, match_id)
              |> Map.put_new(:pixels, subpixels)

            rotated_current =
              edge_matches?(tile, dkey, current)
              |> if do
                # IO.puts("MATCH #{tile_id} #{match_id} - NO ROTATION")
                current
              else
                0..15
                |> Enum.reduce_while({false, current}, fn index, {_is_matched, new_current} ->
                  after_rotation =
                    if rem(index, 3) in [0, 2],
                      do: flip_edges(new_current),
                      else: rotate_edges(new_current)

                  edge_matches?(tile, dkey, after_rotation)
                  |> if do
                    # IO.puts("MATCH #{tile_id} #{match_id}")
                    {:halt, {true, after_rotation}}
                  else
                    {:cont, {false, after_rotation}}
                  end
                end)
                |> case do
                  {false, cur} ->
                    # IO.puts("NO MATCH #{tile_id} #{dkey}")
                    cur

                  {true, cur} ->
                    cur
                end
              end

            Map.put(new_acc, match_id, rotated_current)
        end
      end)
    end)
  end

  def build_row(%{right: nil} = tile, _tile_data), do: [tile |> Map.get(:pixels)]

  def build_row(%{right: right} = tile, tile_data) do
    [tile |> Map.get(:pixels) | build_row(Map.get(tile_data, right), tile_data)]
  end

  def combine_rows(nil, _tile_data), do: []

  def combine_rows(tile_id, tile_data) do
    %{bottom: bottom} = tile = Map.get(tile_data, tile_id)
    row = build_row(tile, tile_data)
    other_rows = combine_rows(bottom, tile_data)
    List.insert_at(other_rows, 0, row)
  end

  def build_image(tile_data) do
    {tile_id, _top_left} =
      Enum.find(tile_data, fn {_tile_id, tile} ->
        is_nil(tile.top) && is_nil(tile.left)
      end)

    combine_rows(tile_id, tile_data)
    |> Enum.map(fn row ->
      size = Enum.count(row)

      Enum.map(1..(@tile_size - 2), fn y ->
        Enum.reduce(0..(size - 1), [], fn block, acc ->
          result =
            row
            |> Enum.at(block)
            |> Enum.at(y)
            |> Enum.slice(1..(@tile_size - 2))

          acc ++ result
        end)
        |> Enum.join("")
      end)
    end)
    |> List.flatten()
  end

  #
  #    ##    ##    ###
  #  #  #  #  #  #
  def count_seamonsters(image, size, iteration \\ 0)
  def count_seamonsters(_image, _size, 16), do: {:error, :not_found}

  def count_seamonsters(image, size, iteration) do
    {_tile_id, tile_map, tile_array} =
      "Tile 1:\n#{image}"
      |> parse_tile()

    Enum.reduce(0..(size - 1), 0, fn y, acc ->
      Enum.reduce(0..(size - 1), acc, fn x, xacc ->
        if Map.get(tile_map, {x, y - 1}) == "#" &&
             Map.get(tile_map, {x + 1, y}) == "#" &&
             Map.get(tile_map, {x + 4, y}) == "#" &&
             Map.get(tile_map, {x + 5, y - 1}) == "#" &&
             Map.get(tile_map, {x + 6, y - 1}) == "#" &&
             Map.get(tile_map, {x + 7, y}) == "#" &&
             Map.get(tile_map, {x + 10, y}) == "#" &&
             Map.get(tile_map, {x + 11, y - 1}) == "#" &&
             Map.get(tile_map, {x + 12, y - 1}) == "#" &&
             Map.get(tile_map, {x + 13, y}) == "#" &&
             Map.get(tile_map, {x + 16, y}) == "#" &&
             Map.get(tile_map, {x + 17, y - 1}) == "#" &&
             Map.get(tile_map, {x + 18, y - 1}) == "#" &&
             Map.get(tile_map, {x + 18, y - 2}) == "#" &&
             Map.get(tile_map, {x + 19, y - 1}) == "#" do
          xacc + 1
        else
          xacc
        end
      end)
    end)
    |> case do
      0 ->
        # Rotate/Flip as needed
        adjusted_image =
          if rem(iteration, 2) == 0 do
            flip_tile(tile_array)
          else
            rotate_tile(tile_array)
          end
          |> Enum.map(fn row ->
            Enum.join(row, "")
          end)
          |> Enum.join("\n")

        adjusted_image
        |> count_seamonsters(size, iteration + 1)

      seamonster_count ->
        {image, seamonster_count}
    end
  end

  #    ##    ##    ###
  def part2(tiles) do
    # Based on discoveries from part 1, nothing had more than 1 match, so we can exit quickly as soon as we find the match.
    edges = Enum.map(tiles, fn {id, {tile, _array}} -> {id, find_edges(tile)} end)

    image =
      Enum.map(edges, fn {id, tile} ->
        {id, find_matches(tile, id, edges)}
      end)
      |> Enum.reduce(%{}, fn {index, edge_list}, acc ->
        translated_edges =
          edge_list
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {edge, idx}, edgeacc ->
            translated_value =
              case edge do
                nil ->
                  nil

                {tile_id, _edge_index} ->
                  tile_id
              end

            Map.put(
              edgeacc,
              translate_edge(idx),
              translated_value
            )
          end)

        Map.put(acc, index, translated_edges)
      end)
      |> determine_rotations(tiles)
      |> build_image()
      |> Enum.join("\n")

    total_waves = String.length(image) - String.length(String.replace(image, ~r/#/, ""))

    {_tile_id, _tile_map, final_tile_array} =
      "Tile 1:\n#{image}"
      |> parse_tile()

    size = Enum.count(final_tile_array)

    image
    |> String.codepoints()
    |> Enum.frequencies()

    count_seamonsters(image, size)
    |> case do
      {:error, :not_found} ->
        "No answer found"

      {_final_image, sea_monsters} ->
        # IO.puts(final_image)
        total_waves - sea_monsters * 15
    end
  end

  def run do
    test_input1 =
      test_input()
      |> parse()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 20899048083289): #{test_result1}")
    test_result2 = part2(test_input1)
    IO.puts("Solution to Test Part 2 (Should be 273): #{inspect(test_result2)}")

    input =
      Advent.daily_input("2020", "20")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end

  def test_input,
    do: """
    Tile 2311:
    ..##.#..#.
    ##..#.....
    #...##..#.
    ####.#...#
    ##.##.###.
    ##...#.###
    .#.#.#..##
    ..#....#..
    ###...#.#.
    ..###..###

    Tile 1951:
    #.##...##.
    #.####...#
    .....#..##
    #...######
    .##.#....#
    .###.#####
    ###.##.##.
    .###....#.
    ..#.#..#.#
    #...##.#..

    Tile 1171:
    ####...##.
    #..##.#..#
    ##.#..#.#.
    .###.####.
    ..###.####
    .##....##.
    .#...####.
    #.##.####.
    ####..#...
    .....##...

    Tile 1427:
    ###.##.#..
    .#..#.##..
    .#.##.#..#
    #.#.#.##.#
    ....#...##
    ...##..##.
    ...#.#####
    .#.####.#.
    ..#..###.#
    ..##.#..#.

    Tile 1489:
    ##.#.#....
    ..##...#..
    .##..##...
    ..#...#...
    #####...#.
    #..#.#.#.#
    ...#.#.#..
    ##.#...##.
    ..##.##.##
    ###.##.#..

    Tile 2473:
    #....####.
    #..#.##...
    #.##..#...
    ######.#.#
    .#...#.#.#
    .#########
    .###.#..#.
    ########.#
    ##...##.#.
    ..###.#.#.

    Tile 2971:
    ..#.#....#
    #...###...
    #.#.###...
    ##.##..#..
    .#####..##
    .#..####.#
    #..#.#..#.
    ..####.###
    ..#.#.###.
    ...#.#.#.#

    Tile 2729:
    ...#.#.#.#
    ####.#....
    ..#.#.....
    ....#..#.#
    .##..##.#.
    .#.####...
    ####.#.#..
    ##.####...
    ##..#.##..
    #.##...##.

    Tile 3079:
    #.#.#####.
    .#..######
    ..#.......
    ######....
    ####.#..#.
    .#...#.##.
    #.#####.##
    ..#.###...
    ..#.......
    ..#.###...
    """
end
