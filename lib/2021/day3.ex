defmodule Aoc202103 do
  import Bitwise

  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  defp check(%{"0" => zeros, "1" => ones}) when zeros > ones, do: 0
  defp check(_), do: 1

  def part1(list) do
    options =
      list
      |> Enum.map(&String.split(&1, "", trim: true))

    items = length(Enum.at(options, 0))

    gamma =
      Enum.reduce(0..(items - 1), %{}, fn x, acc ->
        Map.put(acc, x, check(Enum.frequencies_by(options, &Enum.at(&1, x))))
      end)
      |> Map.values()
      |> Enum.join("")
      |> String.to_integer(2)

    epsilon = trunc(:math.pow(2, items)) - 1 - gamma
    gamma * epsilon
  end

  def part2(list) do
    items = String.length(Enum.at(list, 0))
    values = list |> Enum.map(&String.to_integer(&1, 2))

    o2 =
      Enum.reduce((items - 1)..0, values, fn n, acc ->
        pow = :math.pow(2, n) |> trunc

        {ones, zeros} =
          Enum.reduce(acc, {[], []}, fn value, {one, zero} ->
            if (value &&& pow) == pow, do: {[value] ++ one, zero}, else: {one, [value] ++ zero}
          end)

        if length(zeros) > length(ones), do: zeros, else: ones
      end)
      |> Enum.at(0)

    co2 =
      Enum.reduce((items - 1)..0, values, fn n, acc ->
        pow = :math.pow(2, n) |> trunc

        if length(acc) == 1 do
          acc
        else
          {ones, zeros} =
            Enum.reduce(acc, {[], []}, fn value, {one, zero} ->
              if (value &&& pow) == pow, do: {[value] ++ one, zero}, else: {one, [value] ++ zero}
            end)

          if length(zeros) > length(ones), do: ones, else: zeros
        end
      end)
      |> Enum.at(0)

    o2 * co2
  end

  def run do
    test_input =
      """
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
      """
      |> parse()

    input =
      Advent.daily_input("2021", "03")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
