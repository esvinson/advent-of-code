defmodule Aoc202002 do
  defp test_input,
    do: """
    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc
    """

  defp output_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [min, max, char, password] = String.split(line, ~r/[\n\-: ]/, trim: true)
      {String.to_integer(min), String.to_integer(max), char, password}
    end)
  end

  defp valid_password?({min, max, char, password}) do
    orig_len = String.length(password)

    new_len =
      password
      |> String.replace(char, "")
      |> String.length()

    (orig_len - new_len)
    |> case do
      result when result < min -> false
      result when result > max -> false
      _ -> true
    end
  end

  defp valid_password2?({position1, position2, char, password}) do
    char = String.to_charlist(char) |> Enum.at(0)
    password_chars = String.to_charlist(password)
    first_char = Enum.at(password_chars, position1 - 1)
    second_char = Enum.at(password_chars, position2 - 1)

    cond do
      first_char == char && second_char == char -> false
      first_char == char -> true
      second_char == char -> true
      true -> false
    end
  end

  def part1(list) do
    list
    |> Enum.filter(&valid_password?(&1))
    |> Enum.count()
  end

  def part2(list) do
    list
    |> Enum.filter(&valid_password2?(&1))
    |> Enum.count()
  end

  def run do
    test_list =
      test_input()
      |> String.trim()
      |> output_to_list()

    list =
      Advent.daily_input("2020", "02")
      |> String.trim()
      |> output_to_list()

    testresult1 = part1(test_list)
    IO.puts("Solution to Part 1 Test (should be 2): #{testresult1}")

    result1 = part1(list)
    IO.puts("Solution to Part 1: #{result1}")

    testresult2 = part2(test_list)
    IO.puts("Solution to Part 2 Test (should be 1): #{testresult2}")

    result2 = part2(list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
