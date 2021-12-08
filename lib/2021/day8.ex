defmodule Aoc202108 do
  def parse(input) do
    input
    |> String.split(["\n"], trim: true)
    |> Enum.map(fn row -> String.split(row, " | ", trim: true) end)
  end

  def part1(list) do
    list
    |> Enum.map(fn row ->
      [_, value] = row

      value
      |> String.split(" ", trim: true)
      |> Enum.filter(fn x -> String.length(x) in [2, 3, 4, 7] end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def part2(initial) do
    initial
  end

  def run do
    test_input =
      Advent.daily_input("2021", "08.test")
      |> parse()

    input =
      Advent.daily_input("2021", "08")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
