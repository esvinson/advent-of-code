defmodule Aoc202018 do
  alias Advent.Algorithms

  @doc """
  # Example
  iex> ["1 + 2 * 3 + 4 * 5 + 6" |> Aoc202018.parse()] |> Aoc202018.part1()
  71
  iex> ["1 + (2 * 3) + (4 * (5 + 6))" |> Aoc202018.parse()] |> Aoc202018.part1()
  51
  iex> ["2 * 3 + (4 * 5)" |> Aoc202018.parse()] |> Aoc202018.part1()
  26
  iex> ["5 + (8 * 3 + 9 + 3 * 4 * 3)" |> Aoc202018.parse()] |> Aoc202018.part1()
  437
  iex> ["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" |> Aoc202018.parse()] |> Aoc202018.part1()
  12240
  iex> ["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" |> Aoc202018.parse()] |> Aoc202018.part1()
  13632

  iex> ["1 + 2 * 3 + 4 * 5 + 6" |> Aoc202018.parse()] |> Aoc202018.part2()
  231
  iex> ["1 + (2 * 3) + (4 * (5 + 6))" |> Aoc202018.parse()] |> Aoc202018.part2()
  51
  iex> ["2 * 3 + (4 * 5)" |> Aoc202018.parse()] |> Aoc202018.part2()
  46
  iex> ["5 + (8 * 3 + 9 + 3 * 4 * 3)" |> Aoc202018.parse()] |> Aoc202018.part2()
  1445
  iex> ["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" |> Aoc202018.parse()] |> Aoc202018.part2()
  669060
  iex> ["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" |> Aoc202018.parse()] |> Aoc202018.part2()
  23340
  """

  @operators ["+", "*"]

  def parse(string) do
    string
    |> String.replace("(", "( ")
    |> String.replace(")", " )")
    |> String.split(" ", trim: true)
    |> Enum.map(fn val ->
      case val do
        val when val in [")", "(" | @operators] ->
          val

        val ->
          String.to_integer(val)
      end
    end)
  end

  def part1(input_list) do
    Enum.map(input_list, fn input ->
      input
      |> Algorithms.infix_to_rpn(:none)
      |> Algorithms.rpn_calc()
    end)
    |> Enum.sum()
  end

  def part2(input_list) do
    Enum.map(input_list, fn input ->
      input
      |> Algorithms.infix_to_rpn(:reverse)
      |> Algorithms.rpn_calc()
    end)
    |> Enum.sum()
  end

  def run() do
    input_list =
      Advent.daily_input("2020", "18")
      |> String.split("\n", trim: true)
      |> Enum.map(&parse(&1))

    result1 = part1(input_list)
    IO.puts("Solution to Part 1: #{result1}")
    result2 = part2(input_list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
