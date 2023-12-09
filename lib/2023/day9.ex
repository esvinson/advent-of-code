defmodule Aoc202309 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp differences(set) do
    set
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce([], fn [x, y], acc ->
      [y - x] ++ acc
    end)
    |> Enum.reverse()
  end

  defp reduce_set(row) do
    last = List.last(row)
    diffs = differences(row)
    all_same? = Enum.uniq(diffs) |> length == 1

    if all_same? do
      last + List.first(diffs)
    else
      last + reduce_set(diffs)
    end
  end

  defp part1(sets) do
    sets
    |> Enum.map(fn row ->
      reduce_set(row)
    end)
    |> Enum.sum()
  end

  defp part2(sets) do
    sets
    |> Enum.map(fn row ->
      row
      |> Enum.reverse()
      |> reduce_set()
    end)
    |> Enum.sum()
  end

  def run() do
    test_input =
      """
      0 3 6 9 12 15
      1 3 6 10 15 21
      10 13 16 21 30 45
      """
      |> parse()

    input =
      Advent.daily_input("2023", "09")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
