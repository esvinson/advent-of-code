defmodule Aoc202303 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, index_y}, acc ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {col, index_x}, acc2 ->
        # exclude all . positions when building the map
        if col != ".", do: Map.put(acc2, {index_x, index_y}, col), else: acc2
      end)
    end)
  end

  # return all the points in the surround 8 positions that existing in the map and are digits
  defp adjacent_numbers(map, {x, y}) do
    for(
      i <- -1..1,
      j <- -1..1,
      x + i >= 0 and y + j >= 0 and {i, j} not in [{0, 0}] and Map.has_key?(map, {x + i, y + j}) and
        Regex.match?(~r/^[\d]$/, Map.get(map, {x + i, y + j})),
      do: {x + i, y + j}
    )
  end

  defp parent_position(map, {x, y} = pos) do
    if digit_to_left?(map, pos), do: parent_position(map, {x - 1, y}), else: pos
  end

  defp point_to_number(map, {x, y} = pos) do
    if digit_to_right?(map, pos),
      do: Map.get(map, pos) <> point_to_number(map, {x + 1, y}),
      else: Map.get(map, pos)
  end

  defp find_adjacent(map, filter) do
    map
    |> Map.keys()
    |> Enum.sort(&point_sort/2)
    |> Enum.reduce([], fn pos, acc ->
      if Regex.match?(filter, Map.get(map, pos)) do
        unique_adjacent =
          adjacent_numbers(map, pos)
          |> Enum.map(&parent_position(map, &1))
          # Deduplicate
          |> MapSet.new()
          |> MapSet.to_list()

        [{pos, unique_adjacent}] ++ acc
      else
        acc
      end
    end)
    |> Map.new()
  end

  defp point_sort({_x, y}, {_x2, y2}) when y > y2, do: false
  defp point_sort({_x, y}, {_x2, y2}) when y < y2, do: true
  defp point_sort({x, _y}, {x2, _y2}) when x > x2, do: false
  defp point_sort({x, _y}, {x2, _y2}) when x < x2, do: true
  defp point_sort(_, _), do: true

  defp digit_to_left?(map, {x, y}), do: Regex.match?(~r/\d/, Map.get(map, {x - 1, y}, ""))
  defp digit_to_right?(map, {x, y}), do: Regex.match?(~r/\d/, Map.get(map, {x + 1, y}, ""))

  defp part1(map) do
    map
    # Find everything that's a symbol
    |> find_adjacent(~r/^[^\d]$/)
    |> Enum.reduce(0, fn {_, unique_adjacent}, acc ->
      sum =
        unique_adjacent
        |> Enum.map(&String.to_integer(point_to_number(map, &1)))
        |> Enum.sum()

      acc + sum
    end)
  end

  defp part2(map) do
    map
    # Find all *'s
    |> find_adjacent(~r/^\*$/)
    |> Enum.reduce(0, fn {_, unique_adjacent}, acc ->
      if Enum.count(unique_adjacent) > 1 do
        [i, j] = Enum.map(unique_adjacent, &String.to_integer(point_to_number(map, &1)))

        acc + i * j
      else
        acc
      end
    end)
  end

  def run() do
    test_input =
      """
      467..114..
      ...*......
      ..35..633.
      ......#...
      617*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
      """
      |> parse()

    input =
      Advent.daily_input("2023", "03")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
