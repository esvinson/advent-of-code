defmodule Aoc202107 do
  def parse(input) do
    input
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part1(initial) do
    sorted =
      initial
      |> Enum.sort()

    [max | _rest] = Enum.reverse(sorted)

    fuel =
      Enum.reduce(0..max, [], fn x, acc ->
        [Enum.sum(Enum.map(sorted, &abs(&1 - x)))] ++ acc
      end)
      |> Enum.min()

    fuel
  end

  def part2(initial) do
    sorted =
      initial
      |> Enum.sort()

    [max | _rest] = Enum.reverse(sorted)

    fuel =
      Enum.reduce(0..max, [], fn x, acc ->
        fuel =
          Enum.sum(
            Enum.map(sorted, fn y ->
              diff = abs(y - x)
              div(diff * (diff + 1), 2)
            end)
          )

        [fuel] ++ acc
      end)
      |> Enum.min()

    # |> Enum.reverse()
    # |> Enum.with_index()
    # |> Enum.reduce({:infinity, nil}, fn {x, index}, {current_min, _old_index} = acc ->
    #   if x < current_min, do: {x, index}, else: acc
    # end)

    fuel
  end

  def run do
    test_input = "16,1,2,0,4,2,7,1,2,14" |> parse()

    input =
      Advent.daily_input("2021", "07")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
