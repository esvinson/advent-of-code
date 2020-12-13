defmodule Aoc202013 do
  alias Advent.Algorithms

  def test_input,
    do: """
    939
    7,13,x,x,59,x,31,19
    """

  def test_input2,
    do: """
    939
    1789,37,47,1889
    """

  def input_to_map(input) do
    [target_str, buses] =
      input
      |> to_string()
      |> String.split("\n", trim: true)

    %{
      target: String.to_integer(target_str),
      buses:
        String.split(buses, ",", trim: true)
        |> Enum.reject(&(&1 == "x"))
        |> Enum.map(&String.to_integer(&1))
    }
  end

  def input_to_map_part2(input) do
    [_target_str, buses] =
      input
      |> to_string()
      |> String.split("\n", trim: true)

    String.split(buses, ",", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {x, index} ->
      if x == "x", do: {:ignore, index}, else: {String.to_integer(x), index}
    end)
    |> Enum.reject(fn {x, _index} -> x == :ignore end)
  end

  def part1(input) do
    {first_bus, wait_time} =
      Enum.map(input.buses, fn bus ->
        {bus, bus - rem(input.target, bus)}
      end)
      |> Enum.min(fn {_, a}, {_, b} ->
        a < b
      end)

    first_bus * wait_time
  end

  defp remainders(buses) do
    Enum.reduce(buses, [], fn {val, index}, acc ->
      acc ++ [val - index]
    end)
  end

  defp moduli(buses) do
    Enum.reduce(buses, [], fn {val, _index}, acc ->
      acc ++ [val]
    end)
  end

  def part2(buses) do
    Algorithms.chinese_remainder(moduli(buses), remainders(buses))
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_map()

    input =
      Advent.daily_input("2020", "13")
      |> input_to_map()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 295): #{inspect(test_result1)}")

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    test_input_pt2 =
      test_input()
      |> input_to_map_part2

    test_input_pt2_2 =
      test_input2()
      |> input_to_map_part2

    input_pt2 =
      Advent.daily_input("2020", "13")
      |> input_to_map_part2

    test_result2 = part2(test_input_pt2)
    IO.puts("Solution to Test Part 2 (Should be 1068781): #{inspect(test_result2)}")

    test_result2_2 = part2(test_input_pt2_2)
    IO.puts("Solution to Test Part 2 (Should be 1202161486): #{inspect(test_result2_2)}")

    result2 = part2(input_pt2)
    IO.puts("Solution to Part 2: #{inspect(result2)}")
  end
end
