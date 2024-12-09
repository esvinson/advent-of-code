defmodule Aoc202408 do
  defp parse(input) do
    [first | _rest] =
      start =
      input
      |> String.split("\n", trim: true)

    max_y = Enum.count(start)
    max_x = String.length(first)

    map =
      start
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc1 ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc1, fn {val, x}, acc2 ->
          if val != "." do
            Map.put(acc2, {x, y}, val)
          else
            acc2
          end
        end)
      end)

    %{map: map, height: max_y, width: max_x}
  end

  defp calculate_antinodes({x, y}, {x2, y2}) do
    dx = x2 - x
    dy = y2 - y
    [{x - dx, y - dy}, {x2 + dx, y2 + dy}]
  end

  defp find_antinodes(_last, []), do: []

  defp find_antinodes(first, [second | rest]) do
    calculate_antinodes(first, second) ++
      find_antinodes(first, rest) ++ find_antinodes(second, rest)
  end

  defp part1(%{map: map, height: max_y, width: max_x}) do
    map
    |> Enum.reduce(%{}, fn {key, val}, acc ->
      Map.update(acc, val, [key], fn row ->
        [key] ++ row
      end)
    end)
    |> Enum.reduce(MapSet.new([]), fn {_key, [left | rest]}, acc ->
      Enum.reduce(find_antinodes(left, rest), acc, fn {x, y} = antinode, acc2 ->
        if x < 0 or x >= max_x or y < 0 or y >= max_y do
          acc2
        else
          MapSet.put(acc2, antinode)
        end
      end)
    end)
    |> MapSet.size()
  end

  defp find_start({x, y}, {dx, dy}, max_x, max_y) when x < 0 or x >= max_x or y < 0 or y >= max_y,
    do: {x - dx, y - dy}

  defp find_start({x, y}, {dx, dy}, max_x, max_y),
    do: find_start({x + dx, y + dy}, {dx, dy}, max_x, max_y)

  defp find_all({x, y}, {_dx, _dy}, max_x, max_y) when x < 0 or x >= max_x or y < 0 or y >= max_y,
    do: []

  defp find_all({x, y}, {dx, dy}, max_x, max_y) do
    [{x, y}] ++ find_all({x - dx, y - dy}, {dx, dy}, max_x, max_y)
  end

  defp calculate_antinodes2({x, y}, {x2, y2}, max_x, max_y) do
    dx = x2 - x
    dy = y2 - y
    start = find_start({x, y}, {dx, dy}, max_x, max_y)
    {start, dx, dy}
    find_all(start, {dx, dy}, max_x, max_y)
  end

  defp find_antinodes2(_last, [], _max_x, _max_y), do: []

  defp find_antinodes2(first, [second | rest], max_x, max_y) do
    calculate_antinodes2(first, second, max_x, max_y) ++
      find_antinodes2(first, rest, max_x, max_y) ++ find_antinodes2(second, rest, max_x, max_y)
  end

  defp part2(%{map: map, height: max_y, width: max_x}) do
    map
    |> Enum.reduce(%{}, fn {key, val}, acc ->
      Map.update(acc, val, [key], fn row ->
        [key] ++ row
      end)
    end)
    |> Enum.reduce(MapSet.new([]), fn {_key, [left | rest]}, acc ->
      antinodes = find_antinodes2(left, rest, max_x, max_y)

      Enum.reduce(antinodes, acc, fn antinode, acc2 ->
        MapSet.put(acc2, antinode)
      end)
    end)
    |> MapSet.size()
  end

  def run() do
    test_input =
      """
      ............
      ........0...
      .....0......
      .......0....
      ....0.......
      ......A.....
      ............
      ............
      ........A...
      .........A..
      ............
      ............
      """
      |> parse()

    input =
      Advent.daily_input("2024", "08")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
