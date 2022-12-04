defmodule Aoc202204 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  def part1(assignments) do
    assignments
    |> Enum.reduce(0, fn set, acc ->
      [left, right] =
        set
        |> String.split(",", trim: true)

      [start, stop] = String.split(left, "-", trim: true) |> Enum.map(&String.to_integer/1)
      first = MapSet.new(Range.new(start, stop))
      [start, stop] = String.split(right, "-", trim: true) |> Enum.map(&String.to_integer/1)
      second = MapSet.new(Range.new(start, stop))

      if MapSet.subset?(first, second) or MapSet.subset?(second, first) do
        acc + 1
      else
        acc
      end
    end)
  end

  def part2(assignments) do
    assignments
    |> Enum.reduce(0, fn set, acc ->
      [left, right] =
        set
        |> String.split(",", trim: true)

      [start, stop] = String.split(left, "-", trim: true) |> Enum.map(&String.to_integer/1)
      first = MapSet.new(Range.new(start, stop))
      [start, stop] = String.split(right, "-", trim: true) |> Enum.map(&String.to_integer/1)
      second = MapSet.new(Range.new(start, stop))

      if MapSet.disjoint?(first, second) do
        acc
      else
        acc + 1
      end
    end)
  end

  def run do
    test_input =
      """
      2-4,6-8
      2-3,4-5
      5-7,7-9
      2-8,3-7
      6-6,4-6
      2-6,4-8
      """
      |> parse

    input =
      Advent.daily_input("2022", "04")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
