defmodule Aoc202206 do
  def parse(input) do
    String.trim(input)
  end

  def part1(start) do
    start
    |> String.to_charlist()
    |> Enum.chunk_every(4, 1)
    |> Enum.reduce_while(4, fn row, acc ->
      if Enum.count(Enum.uniq(row)) == 4 do
        {:halt, acc}
      else
        {:cont, acc + 1}
      end
    end)
  end

  def part2(start) do
    start
    |> String.to_charlist()
    |> Enum.chunk_every(14, 1)
    |> Enum.reduce_while(14, fn row, acc ->
      if Enum.count(Enum.uniq(row)) == 14 do
        {:halt, acc}
      else
        {:cont, acc + 1}
      end
    end)
  end

  def run do
    test_input = "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"

    input = Advent.daily_input("2022", "06")

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
