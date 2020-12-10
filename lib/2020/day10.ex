defmodule Aoc202010 do
  def test_input,
    do: """
    28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3
    """

  def input_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer(&1))
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {val, index}, acc ->
      Map.put(acc, index, val)
    end)
  end

  def part1(list) do
    diffs =
      list
      |> Map.keys()
      |> Enum.sort()
      |> Enum.reduce(%{}, fn x, acc ->
        diff = Map.get(list, x, 0) - Map.get(list, x - 1, 0)
        Map.put(acc, diff, Map.get(acc, diff, 0) + 1)
      end)

    Map.get(diffs, 1, 0) * (Map.get(diffs, 3, 0) + 1)
  end

  def traverse(_list, -1, state), do: {1, state}

  def traverse(list, position, state) do
    Map.get(state, position, false)
    |> case do
      false ->
        current_val = list[position]

        Enum.reduce_while(1..3, {0, state}, fn x, {incrementer, current_state} ->
          if position - x >= -1 && current_val - Map.get(list, position - x) <= 3 do
            {new_val, new_state} = traverse(list, position - x, current_state)

            new_state = Map.put(new_state, position - x, new_val)

            {:cont, {incrementer + new_val, new_state}}
          else
            {:halt, {incrementer, current_state}}
          end
        end)

      val ->
        {val, state}
    end
  end

  def part2(list) do
    size = Enum.count(Map.keys(list))

    list
    |> Map.put(-1, 0)
    |> Map.put(size, list[size - 1] + 3)
    |> traverse(size, %{})
    |> elem(0)
  end

  def run do
    test_list =
      test_input()
      |> input_to_list()

    list =
      Advent.daily_input("2020", "10")
      |> input_to_list()

    test_result1 = part1(test_list)
    IO.puts("Solution to Test Part 1 (Should be 220): #{test_result1}")

    result1 = part1(list)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2 = part2(test_list)
    IO.puts("Solution to Test Part 2 (Should be 19208): #{test_result2}")

    result2 = part2(list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
