defmodule Aoc202401 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [left, right] = String.split(row, ~r/\s+/, trim: true)
      {String.to_integer(left), String.to_integer(right)}
    end)
  end

  defp sum_differences([], []), do: 0

  defp sum_differences([left | rest_left], [right | rest_right]) do
    abs(left - right) + sum_differences(rest_left, rest_right)
  end

  defp part1(input) do
    {first_list, second_list} =
      input
      |> Enum.reduce({[], []}, fn {left, right}, {left_acc, right_acc} ->
        {[left] ++ left_acc, [right] ++ right_acc}
      end)

    first_list = Enum.sort(first_list)
    second_list = Enum.sort(second_list)
    sum_differences(first_list, second_list)
  end

  defp part2(input) do
    {first_list, second_list} =
      input
      |> Enum.reduce({[], []}, fn {left, right}, {left_acc, right_acc} ->
        {[left] ++ left_acc, [right] ++ right_acc}
      end)

    freq = second_list |> Enum.frequencies()
    first_list |> Enum.map(fn num -> Map.get(freq, num, 0) * num end) |> Enum.sum()
  end

  def run() do
    test_input =
      """
      3   4
      4   3
      2   5
      1   3
      3   9
      3   3
      """
      |> parse()

    input =
      Advent.daily_input("2024", "01")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
