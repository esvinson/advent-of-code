defmodule Aoc202506 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      vals = String.split(row, ~r{\s+}, trim: true)

      if String.match?(Enum.at(vals, 0), ~r{^\d+$}) do
        Enum.map(vals, &String.to_integer/1)
      else
        vals
      end
    end)
  end

  defp calculate(["*" | rest]),
    do:
      Enum.reduce(rest, 1, fn val, acc ->
        val * acc
      end)

  defp calculate(["+" | rest]), do: Enum.sum(rest)

  defp part1(input) do
    input
    |> Enum.zip()
    |> Enum.map(fn problem ->
      problem
      |> Tuple.to_list()
      |> Enum.reverse()
      |> calculate()
    end)
    |> Enum.sum()
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      123 328  51 64
      45 64  387 23
      6 98  215 314
      *   +   *   +
      """
      |> parse()

    input =
      Advent.daily_input("2025", "06")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
