defmodule Aoc202201 do
  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn inventory ->
      inventory
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)

  end

  def part1(inventory) do
    inventory
    |> Enum.map(&Enum.sum(&1))
    |> Enum.max()
  end

  def part2(inventory) do
    inventory
    |> Enum.map(&Enum.sum(&1))
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  def run do
    test_input =
      """
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
      """
      |> parse

    input =
      Advent.daily_input("2022", "01")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
