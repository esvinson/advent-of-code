defmodule Aoc202313 do
  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn area ->
      area
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
    end)
  end

  defp check_rest(position, offset, set) do
    val = Map.get(set, position + offset, false)
    val2 = Map.get(set, position - (1 + offset), false)

    if val == false or val2 == false do
      true
    else
      first = Map.get(set, position + offset)
      second = Map.get(set, position - (offset + 1))

      if first == second do
        check_rest(position, offset + 1, set)
      end
    end
  end

  defp find_mirror(0, _set), do: false

  defp find_mirror(position, set) do
    first = Map.get(set, position, [])
    second = Map.get(set, position - 1, [])

    if first == second and check_rest(position, 1, set) do
      position
    else
      find_mirror(position - 1, set)
    end
  end

  defp part1(mirrors) do
    %{rows: y, cols: x} = iterate(mirrors)

    y * 100 + x
  end

  defp map_mirrors(mirrors) do
    mirrors
    |> Enum.map(fn set ->
      total_rows = Enum.count(set)

      rows =
        set
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {row, key}, acc ->
          Map.put(acc, key, row)
        end)

      total_cols = Map.get(rows, 0, []) |> Enum.count()

      cols =
        set
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {row, _key}, acc ->
          row
          |> Enum.with_index()
          |> Enum.reduce(acc, fn {col, subkey}, subacc ->
            new_val = Map.get(subacc, subkey, []) ++ [col]
            Map.put(subacc, subkey, new_val)
          end)
        end)

      {total_rows, total_cols, rows, cols}
    end)
  end

  defp iterate(mirrors) do
    mirrors
    |> map_mirrors()
    |> Enum.reduce(%{rows: 0, cols: 0}, fn {total_rows, total_cols, rows, cols},
                                           %{rows: row_val, cols: col_val} = acc ->
      val = find_mirror(total_rows - 1, rows)

      if val,
        do: Map.put(acc, :rows, row_val + val),
        else: Map.put(acc, :cols, col_val + find_mirror(total_cols - 1, cols))
    end)
  end

  defp part2(mirrors) do
    mirrors
    |> map_mirrors()
    |> Enum.map(fn {rows, cols, _, _} ->
      rows * cols
    end)
    |> Enum.sum()

    # %{rows: original_y, cols: original_x} = iterate(mirrors)
  end

  def run() do
    test_input =
      """
      #.##..##.
      ..#.##.#.
      ##......#
      ##......#
      ..#.##.#.
      ..##..##.
      #.#.##.#.

      #...##..#
      #....#..#
      ..##..###
      #####.##.
      #####.##.
      ..##..###
      #....#..#
      """
      |> parse()

    input =
      Advent.daily_input("2023", "13")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
