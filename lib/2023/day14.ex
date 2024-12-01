defmodule Aoc202314 do
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
    #   Advent.daily_input("2023", "14")
    #   |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    # IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
