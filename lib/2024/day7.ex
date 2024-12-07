defmodule Aoc202407 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [result_str, numbers_str] = String.split(row, ":", trim: true)
      result = String.to_integer(result_str)
      numbers = numbers_str |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
      {result, numbers}
    end)
  end

  defp calculate([], _operators, val, result) when val == result, do: true
  defp calculate([], _operators, val, result) when val != result, do: false

  defp calculate([x | rest], operators, val, result) do
    Enum.reduce_while(operators, false, fn operator, _acc ->
      new_val = apply(operator, [val, x])

      if calculate(rest, operators, new_val, result) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  defp part1(input) do
    input
    |> Enum.map(fn {result, [first | rest]} ->
      if calculate(rest, [&Kernel.+/2, &Kernel.*/2], first, result) do
        result
      else
        0
      end
    end)
    |> Enum.sum()
  end

  defp combine(x, y), do: String.to_integer("#{x}#{y}")

  defp part2(input) do
    input
    |> Enum.map(fn {result, [first | rest]} ->
      if calculate(rest, [&Kernel.+/2, &Kernel.*/2, &combine/2], first, result) do
        result
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def run() do
    test_input =
      """
      190: 10 19
      3267: 81 40 27
      83: 17 5
      156: 15 6
      7290: 6 8 6 15
      161011: 16 10 13
      192: 17 8 14
      21037: 9 7 18 13
      292: 11 6 16 20
      """
      |> parse()

    input =
      Advent.daily_input("2024", "07")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
