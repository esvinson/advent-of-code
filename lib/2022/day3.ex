defmodule Aoc202203 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  defp calculate(val) do
    if val in Enum.to_list(Range.new(?a, ?z)) do
      val - ?a + 1
    else
      val - ?A + 27
    end
  end

  def part1(backpacks) do
    backpacks
    |> Enum.map(fn row ->
      split = div(String.length(row), 2)

      {left, right} = String.split_at(row, split)
      {String.to_charlist(left), String.to_charlist(right)}
    end)
    |> Enum.map(fn {left, right} ->
      Enum.reduce_while(left, nil, fn val, _acc ->
        if Enum.member?(right, val) do
          {:halt, val}
        else
          {:cont, nil}
        end
      end)
    end)
    |> Enum.map(&calculate(&1))
    |> Enum.sum()
  end

  def part2(backpacks) do
    backpacks
    |> Enum.map(&String.to_charlist(&1))
    |> Enum.chunk_every(3)
    |> Enum.map(fn [left, center, right] ->
      Enum.reduce_while(left, nil, fn val, _acc ->
        if Enum.member?(center, val) and Enum.member?(right, val) do
          {:halt, val}
        else
          {:cont, nil}
        end
      end)
    end)
    |> Enum.map(&calculate(&1))
    |> Enum.sum()
  end

  def run do
    test_input =
      """
      vJrwpWtwJgWrhcsFMMfFFhFp
      jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      PmmdzqPrVvPwwTWBwg
      wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ttgJtRGJQctTZtZT
      CrZsJsPPZsGzwwsLwLmpwMDw
      """
      |> parse

    input =
      Advent.daily_input("2022", "03")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
