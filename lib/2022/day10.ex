defmodule Aoc202210 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  def part1(commands) do
    {_, output} =
      commands
      |> List.flatten()
      |> Enum.with_index(1)
      |> Enum.reduce({1, 0}, fn {val, index}, {calc, acc} ->
        new_calc =
          val
          |> case do
            "noop" -> calc
            "addx" -> calc
            _ -> calc + String.to_integer(val)
          end

        new_acc = if index in [20, 60, 100, 140, 180, 220], do: acc + index * calc, else: acc
        {new_calc, new_acc}
      end)

    output
  end

  def part2(commands) do
    commands
  end

  def run do
    test_input = Advent.daily_input("2022", "10.test") |> parse()
    input = Advent.daily_input("2022", "10") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
