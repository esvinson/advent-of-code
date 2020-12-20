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

    {tile_id, tile_map}
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(%{}, fn unparsed_tile, acc ->
      {tile_id, tile} = parse_tile(unparsed_tile)
      Map.put(acc, tile_id, tile)
    end)
  end

  def find_edges(tile) do
    max_index = @tile_size - 1
    # tile
    # |> Enum.filter(fn {{x, y}, _val} ->

    #   {x, y}
    #   |> case do
    #     {_x, 0} -> true
    #     {_x, y} when y == max_index -> true
    #     {0, _y} -> true
    #     {x, _y} when x == max_index -> true
    #     _ -> false
    #   end
    # end)
    # |> Map.new()
    # |> IO.inspect()

    Enum.reduce(0..3, [], fn edge_num, acc ->
      edge =
        edge_num
        |> case do
          0 ->
            Enum.map(0..max_index, fn y ->
              Map.get(tile, {0, y})
            end)

          1 ->
            Enum.map(0..max_index, fn x ->
              Map.get(tile, {x, 0})
            end)

          2 ->
            Enum.map(0..max_index, fn y ->
              Map.get(tile, {max_index, y})
            end)

          3 ->
            Enum.map(0..max_index, fn x ->
              Map.get(tile, {x, max_index})
            end)
        end
        |> Enum.join("")

      [edge | acc]
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
    edges = Enum.map(tiles, fn {id, tile} -> {id, find_edges(tile)} end)

    Enum.map(edges, fn {id, tile} ->
      {id, count_matches(tile, id, edges) |> Enum.frequencies()}
    end)
    |> Enum.filter(fn {_id, freqs} ->
      freqs[0] == 2
    end)
    |> Enum.reduce(1, fn {id, _freq}, acc -> id * acc end)
  end

  def run do
    test_input1 =
      test_input()
      |> parse()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 20899048083289): #{test_result1}")

    input =
      Advent.daily_input("2020", "20")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")
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
