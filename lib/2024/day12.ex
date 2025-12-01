defmodule Aoc202412 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  defp part1(input) do
    input
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      """
      |> parse()

    # input =
    #   Advent.daily_input("2024", "12")
    #   |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    # IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
