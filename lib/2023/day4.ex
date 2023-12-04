defmodule Aoc202304 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [card, rest] = String.split(row, ": ", trim: true)
      card = Regex.run(~r/(\d+)/, card) |> List.last()
      [left, right] = String.split(rest, " | ", trim: true)
      left = String.split(left, " ", trim: true)
      right = String.split(right, " ", trim: true)
      {card, {MapSet.new(left), MapSet.new(right)}}
    end)
  end

  defp part1(cards) do
    cards
    |> Enum.map(fn {_card, {left, right}} ->
      val = MapSet.intersection(left, right) |> Enum.count()
      if val > 0, do: 2 ** (val - 1), else: 0
    end)
    |> Enum.sum()
  end

  defp part2(input) do
    input
  end

  def run() do
    test_input =
      """
      Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
      Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
      Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
      Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
      Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
      Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
      """
      |> parse()

    input =
      Advent.daily_input("2023", "04")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
