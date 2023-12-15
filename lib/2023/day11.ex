defmodule Aoc202311 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp rows_with_galaxies(galaxy_map) do
    galaxy_map
    |> Enum.with_index()
    |> Enum.reduce([], fn {val, key}, acc ->
      has_galaxy? =
        val
        |> Enum.frequencies()
        |> Map.has_key?("#")

      if not has_galaxy?, do: [key] ++ acc, else: acc
    end)
  end

  defp cols_with_galaxies(galaxy_map) do
    galaxy_map
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, x}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {col, y}, subacc ->
        if x == 0 do
          Map.put(subacc, y, [col])
        else
          prev = Map.get(subacc, y)
          Map.put(subacc, y, [col] ++ prev)
        end
      end)
    end)
    |> Enum.reduce([], fn {key, val}, acc ->
      has_galaxy? =
        val
        |> Enum.frequencies()
        |> Map.has_key?("#")

      if not has_galaxy?, do: [key] ++ acc, else: acc
    end)
  end

  defp map_galaxies(galaxy_map) do
    galaxy_map
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {col, x}, subacc ->
        if col == "#", do: [{x, y}] ++ subacc, else: subacc
      end)
    end)
  end

  defp overlaps([], _first, _second), do: 0

  defp overlaps([compare | rest], first, second) when compare > first and compare < second,
    do: 1 + overlaps(rest, first, second)

  defp overlaps([_compare | rest], first, second), do: overlaps(rest, first, second)

  defp distance(galaxies, no_galaxy_rows, no_galaxy_cols, multiplier \\ 2)
  defp distance([], _no_galaxy_rows, _no_galaxy_cols, _multiplier), do: []

  defp distance([{x1, y1} | rest], no_galaxy_rows, no_galaxy_cols, multiplier) do
    distances =
      Enum.reduce(rest, [], fn {x2, y2}, acc ->
        {xmax, xmin} = if x1 > x2, do: {x1, x2}, else: {x2, x1}
        {ymax, ymin} = if y1 > y2, do: {y1, y2}, else: {y2, y1}

        overlaps_x = overlaps(no_galaxy_cols, xmin, xmax)
        overlaps_y = overlaps(no_galaxy_rows, ymin, ymax)

        x = abs(x2 - x1) + overlaps_x * multiplier - overlaps_x
        y = abs(y2 - y1) + overlaps_y * multiplier - overlaps_y
        [x + y] ++ acc
      end)

    distances ++ distance(rest, no_galaxy_rows, no_galaxy_cols, multiplier)
  end

  defp part1(galaxy_map) do
    rows = rows_with_galaxies(galaxy_map)
    cols = cols_with_galaxies(galaxy_map)
    mapping = map_galaxies(galaxy_map)

    distance(mapping, rows, cols)
    |> Enum.sum()
  end

  defp part2(galaxy_map, multiplier \\ 1_000_000) do
    rows = rows_with_galaxies(galaxy_map)
    cols = cols_with_galaxies(galaxy_map)
    mapping = map_galaxies(galaxy_map)

    distance(mapping, rows, cols, multiplier)
    |> Enum.sum()
  end

  def run() do
    test_input =
      """
      ...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#.....
      """
      |> parse()

    input =
      Advent.daily_input("2023", "11")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2 (10): #{inspect(part2(test_input, 10))}")
    IO.puts("Test Answer Part 2 (100): #{inspect(part2(test_input, 100))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
