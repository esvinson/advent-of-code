defmodule Aoc202202 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  def do_round(["A", "X"]), do: 1 + 3
  def do_round(["A", "Y"]), do: 2 + 6
  def do_round(["A", "Z"]), do: 3 + 0
  def do_round(["B", "X"]), do: 1 + 0
  def do_round(["B", "Y"]), do: 2 + 3
  def do_round(["B", "Z"]), do: 3 + 6
  def do_round(["C", "X"]), do: 1 + 6
  def do_round(["C", "Y"]), do: 2 + 0
  def do_round(["C", "Z"]), do: 3 + 3

  def part1(rounds) do
    rounds
    |> Enum.map(&do_round(&1))
    |> Enum.sum()
  end

  def part2(inventory) do
    inventory
  end

  def run do
    test_input =
      """
      A Y
      B X
      C Z
      """
      |> parse

    input =
      Advent.daily_input("2022", "02")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
