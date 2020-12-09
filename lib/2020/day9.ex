defmodule Aoc202009 do
  def input_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {val, index}, acc ->
      Map.put(acc, index, String.to_integer(val))
    end)
  end

  def get_list(numbers, offset) do
    Enum.reduce(1..25, [], fn x, acc ->
      [Map.get(numbers, offset - x)] ++ acc
    end)
  end

  defp drop_gt(list, current), do: Enum.filter(list, fn x -> x < current end)

  defp check_for_sum([], current), do: {:error, current}

  defp check_for_sum([first | rest], current) do
    Enum.reduce_while(rest, false, fn x, _acc ->
      cond do
        first + x == current -> {:halt, {first, x, current}}
        true -> {:cont, false}
      end
    end)
    |> case do
      false ->
        check_for_sum(rest, current)

      result ->
        {:ok, result}
    end
  end

  def check(numbers, offset) do
    current = Map.get(numbers, offset)

    get_list(numbers, offset)
    |> drop_gt(current)
    |> check_for_sum(current)
    |> case do
      {:ok, _result} ->
        check(numbers, offset + 1)

      {:error, val} ->
        {offset, val}
    end
  end

  def part1(numbers) do
    numbers
    |> check(25)
  end

  def find_it(_numbers, -1, _max_offset, _value), do: false
  def find_it(_numbers, _min_offset, -1, _value), do: false

  def find_it(numbers, min_offset, max_offset, value) do
    total =
      Enum.reduce(min_offset..max_offset, 0, fn x, acc ->
        acc + Map.get(numbers, x)
      end)

    cond do
      total == value and min_offset != max_offset -> {min_offset, max_offset}
      total < value -> find_it(numbers, min_offset - 1, max_offset, value)
      total > value -> find_it(numbers, min(min_offset, max_offset - 1), max_offset - 1, value)
      true -> find_it(numbers, min_offset - 1, max_offset - 1, value)
    end
  end

  def part2(numbers, {offset, value}) do
    {min_offset, max_offset} = find_it(numbers, offset + 25, offset + 25, value)

    {min_value, max_value} =
      Enum.reduce(min_offset..max_offset, {value, -value}, fn x, {min, max} ->
        val = Map.get(numbers, x)
        new_min = if val < min, do: val, else: min
        new_max = if val > max, do: val, else: max
        {new_min, new_max}
      end)

    min_value + max_value
  end

  def run do
    numbers =
      Advent.daily_input("2020", "09")
      |> input_to_list()

    {_, result1} =
      answer =
      numbers
      |> part1()

    IO.puts("Solution to Part 1: #{result1}")

    results2 = part2(numbers, answer)
    IO.puts("Solution to Part 2: #{results2}")
  end
end
