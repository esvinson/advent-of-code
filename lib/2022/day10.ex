defmodule Aoc202210 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> List.flatten()
    |> Enum.map(fn
      "noop" -> "noop"
      "addx" -> "addx"
      val -> String.to_integer(val)
    end)
  end

  def part1(commands) do
    {_, output} =
      commands
      |> Enum.with_index(1)
      |> Enum.reduce({1, 0}, fn {val, index}, {calc, acc} ->
        new_calc = if is_integer(val), do: calc + val, else: calc
        new_acc = if index in [20, 60, 100, 140, 180, 220], do: acc + index * calc, else: acc
        {new_calc, new_acc}
      end)

    output
  end

  def part2(commands) do
    {_, output} =
      commands
      |> Enum.with_index()
      |> Enum.reduce({1, []}, fn {val, index}, {calc, acc} ->
        new_index = rem(index, 40)
        char = if new_index in [calc - 1, calc, calc + 1], do: "#", else: "."
        new_calc = if is_integer(val), do: calc + val, else: calc
        {new_calc, [char] ++ acc}
      end)

    output
    |> Enum.reverse()
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.each(fn row -> IO.puts(row) end)
  end

  def run do
    test_input = Advent.daily_input("2022", "10.test") |> parse()
    input = Advent.daily_input("2022", "10") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2:")
    part2(test_input)
    IO.puts("Part 2:")
    part2(input)
  end
end
