defmodule Aoc202202 do
  @alpha_rock "A"
  @alpha_paper "B"
  @alpha_scissors "C"
  @rock 1
  @paper 2
  @scissors 3
  @win 6
  @lose 0
  @draw 3

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  def part1_round([@alpha_rock, "X"]), do: @rock + @draw
  def part1_round([@alpha_rock, "Y"]), do: @paper + @win
  def part1_round([@alpha_rock, "Z"]), do: @scissors + @lose
  def part1_round([@alpha_paper, "X"]), do: @rock + @lose
  def part1_round([@alpha_paper, "Y"]), do: @paper + @draw
  def part1_round([@alpha_paper, "Z"]), do: @scissors + @win
  def part1_round([@alpha_scissors, "X"]), do: @rock + @win
  def part1_round([@alpha_scissors, "Y"]), do: @paper + @lose
  def part1_round([@alpha_scissors, "Z"]), do: @scissors + @draw

  def part1(rounds) do
    rounds
    |> Enum.map(&part1_round(&1))
    |> Enum.sum()
  end

  def part2_round([@alpha_rock, "X"]), do: @scissors + @lose
  def part2_round([@alpha_rock, "Y"]), do: @rock + @draw
  def part2_round([@alpha_rock, "Z"]), do: @paper + @win
  def part2_round([@alpha_paper, "X"]), do: @rock + @lose
  def part2_round([@alpha_paper, "Y"]), do: @paper + @draw
  def part2_round([@alpha_paper, "Z"]), do: @scissors + @win
  def part2_round([@alpha_scissors, "X"]), do: @paper + @lose
  def part2_round([@alpha_scissors, "Y"]), do: @scissors + @draw
  def part2_round([@alpha_scissors, "Z"]), do: @rock + @win

  def part2(rounds) do
    rounds
    |> Enum.map(&part2_round(&1))
    |> Enum.sum()
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
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
