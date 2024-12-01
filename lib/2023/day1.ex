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

  def words_to_numbers("", output), do: output
  def words_to_numbers("one" <> rest, output), do: words_to_numbers("e" <> rest, output <> "1")
  def words_to_numbers("two" <> rest, output), do: words_to_numbers("o" <> rest, output <> "2")
  def words_to_numbers("three" <> rest, output), do: words_to_numbers("e" <> rest, output <> "3")
  def words_to_numbers("four" <> rest, output), do: words_to_numbers("r" <> rest, output <> "4")
  def words_to_numbers("five" <> rest, output), do: words_to_numbers("e" <> rest, output <> "5")
  def words_to_numbers("six" <> rest, output), do: words_to_numbers("x" <> rest, output <> "6")
  def words_to_numbers("seven" <> rest, output), do: words_to_numbers("n" <> rest, output <> "7")
  def words_to_numbers("eight" <> rest, output), do: words_to_numbers("t" <> rest, output <> "8")
  def words_to_numbers("nine" <> rest, output), do: words_to_numbers("e" <> rest, output <> "9")

  def words_to_numbers(rest, output) do
    first = String.first(rest)
    rest = String.slice(rest, 1..-1//1)

    if String.match?(first, ~r/^\d/) do
      words_to_numbers(rest, output <> first)
    else
      words_to_numbers(rest, output)
    end
  end

  def part2(rows) do
    rows
    |> Enum.map(fn row ->
      numbers = words_to_numbers(row, "")
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
