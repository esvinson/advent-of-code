defmodule Aoc202108 do
  def parse(input) do
    input
    |> String.split(["\n"], trim: true)
    |> Enum.map(fn row -> String.split(row, " | ", trim: true) end)
  end

  def part1(list) do
    list
    |> Enum.map(fn row ->
      [_, value] = row

      value
      |> String.split(" ", trim: true)
      |> Enum.filter(fn x -> String.length(x) in [2, 3, 4, 7] end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp solve_row(input, output) do
    [one] = Enum.filter(input, &(length(&1) == 2))
    [seven] = Enum.filter(input, &(length(&1) == 3))
    [four] = Enum.filter(input, &(length(&1) == 4))
    [eight] = Enum.filter(input, &(length(&1) == 7))
    [two] = Enum.filter(input, &(length(&1) == 5 and length(four -- &1) == 2))
    [three] = Enum.filter(input, &(length(&1) == 5 and length(one -- &1) == 0))
    [six] = Enum.filter(input, &(length(&1) == 6 and length(one -- &1) == 1))
    [nine] = Enum.filter(input, &(length(&1) == 6 and length(four -- &1) == 0))

    [zero] =
      Enum.filter(
        input,
        &(length(&1) == 6 and length(four -- &1) == 1 and length(one -- &1) == 0)
      )

    [five] =
      Enum.filter(
        input,
        &(length(&1) == 5 and length(four -- &1) == 1 and length(one -- &1) == 1)
      )

    mapping = [zero, one, two, three, four, five, six, seven, eight, nine]

    output
    |> Enum.map(fn set ->
      Enum.find_index(mapping, &(&1 == set))
    end)
    |> Integer.undigits()
  end

  def part2(initial) do
    Enum.map(initial, fn [input, output] ->
      input =
        input
        |> String.split(" ", trim: true)
        |> Enum.map(fn signals ->
          signals
          |> String.split("", trim: true)
          |> Enum.sort()
        end)

      output =
        output
        |> String.split(" ", trim: true)
        |> Enum.map(fn signals ->
          signals
          |> String.split("", trim: true)
          |> Enum.sort()
        end)

      solve_row(input |> Enum.sort_by(&length/1), output)
    end)
    |> Enum.sum()

    # 0 = length 6, three segments from 4, and all from 1
    # 1 = length 2
    # 2 = length 5, two segments from 4
    # 3 = length 5, all segments from 1
    # 4 = length 4
    # 5 = length 5, three segments from 4
    # 6 = length 6, one segment from 1
    # 7 = length 3
    # 8 = length 7
    # 9 = length 6, all segments from 4
  end

  def run do
    test_input =
      Advent.daily_input("2021", "08.test")
      |> parse()

    input =
      Advent.daily_input("2021", "08")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
