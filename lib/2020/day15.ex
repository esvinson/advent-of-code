defmodule Aoc202015 do
  def test_input, do: [0, 3, 6]

  def part1(list) do
    initial_state =
      list
      |> Enum.with_index()
      |> Enum.reduce({nil, %{}}, fn {val, index}, {_, acc} ->
        {val, Map.put(acc, val, [index])}
      end)

    start_offset = Enum.count(list)

    Enum.reduce(start_offset..2019, initial_state, fn offset, {prev_value, state} ->
      new_val =
        Map.get(state, prev_value)
        |> case do
          [_x] ->
            0

          [x1, x2 | _rest] ->
            x1 - x2
        end

      {new_val, Map.put(state, new_val, [offset | Map.get(state, new_val, [])])}
    end)
    |> elem(0)
  end

  def part2(list) do
    initial_state =
      list
      |> Enum.with_index()
      |> Enum.reduce({nil, %{}}, fn {val, index}, {_, acc} ->
        {val, Map.put(acc, val, [index])}
      end)

    start_offset = Enum.count(list)

    Enum.reduce(start_offset..29_999_999, initial_state, fn offset, {prev_value, state} ->
      new_val =
        Map.get(state, prev_value)
        |> case do
          [_x] ->
            0

          [x1, x2 | _rest] ->
            x1 - x2
        end

      {new_val, Map.put(state, new_val, [offset | Map.get(state, new_val, [])])}
    end)
    |> elem(0)
  end

  def run do
    test_result1 = part1(test_input())
    IO.puts("Solution to Test Part 1 (Should be 436): #{inspect(test_result1)}")

    result1 = part1([1, 0, 18, 10, 19, 6])
    IO.puts("Solution to Part 1: #{inspect(result1)}")

    test_result2 = part2(test_input())
    IO.puts("Solution to Test Part 2 (Should be 175594): #{inspect(test_result2)}")

    result2 = part2([1, 0, 18, 10, 19, 6])
    IO.puts("Solution to Part 2: #{inspect(result2)}")
  end
end
