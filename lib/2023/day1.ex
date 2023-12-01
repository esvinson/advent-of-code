defmodule Aoc202301 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  def part1(rows) do
    rows
    |> Enum.map(fn row ->
      numbers =
        row
        |> String.replace(~r/[^\d]/, "")

      String.to_integer(String.first(numbers) <> String.last(numbers))
    end)
    |> Enum.sum()
  end

  def convert("", output), do: output
  def convert("one" <> rest, output), do: convert("e" <> rest, output <> "1")
  def convert("two" <> rest, output), do: convert("o" <> rest, output <> "2")
  def convert("three" <> rest, output), do: convert("e" <> rest, output <> "3")
  def convert("four" <> rest, output), do: convert("r" <> rest, output <> "4")
  def convert("five" <> rest, output), do: convert("e" <> rest, output <> "5")
  def convert("six" <> rest, output), do: convert("x" <> rest, output <> "6")
  def convert("seven" <> rest, output), do: convert("n" <> rest, output <> "7")
  def convert("eight" <> rest, output), do: convert("t" <> rest, output <> "8")
  def convert("nine" <> rest, output), do: convert("e" <> rest, output <> "9")

  def convert(rest, output) do
    first = String.first(rest)
    rest = String.slice(rest, 1..-1)

    if String.match?(first, ~r/^\d/) do
      convert(rest, output <> first)
    else
      convert(rest, output)
    end
  end

  def part2(rows) do
    rows
    |> Enum.map(fn row ->
      numbers = convert(row, "")
      String.to_integer(String.first(numbers) <> String.last(numbers))
    end)
    |> Enum.sum()
  end

  def run do
    test_input =
      """
      1abc2
      pqr3stu8vwx
      a1b2c3d4e5f
      treb7uchet
      """
      |> parse

    test_input2 =
      """
      two1nine
      eightwothree
      abcone2threexyz
      xtwone3four
      4nineeightseven2
      zoneight234
      7pqrstsixteen
      """
      |> parse

    input =
      Advent.daily_input("2023", "01")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input2))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
