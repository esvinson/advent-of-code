defmodule Aoc202102 do
  def direction("forward"), do: :forward
  def direction("down"), do: :down
  def direction("up"), do: :up

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [dir, size] =
        row
        |> String.split(" ", trim: true)

      {direction(dir), String.to_integer(size)}
    end)
  end

  defp move(%{distance: distance, depth: depth, aim: aim}, {:up, val}),
    do: %{distance: distance, depth: depth, aim: aim - val}

  defp move(%{distance: distance, depth: depth, aim: aim}, {:down, val}),
    do: %{distance: distance, depth: depth, aim: aim + val}

  defp move(%{distance: distance, depth: depth, aim: aim}, {:forward, val}),
    do: %{distance: distance + val, depth: depth + aim * val, aim: aim}

  defp move(%{distance: distance, depth: depth}, {:up, val}),
    do: %{distance: distance, depth: depth - val}

  defp move(%{distance: distance, depth: depth}, {:down, val}),
    do: %{distance: distance, depth: depth + val}

  defp move(%{distance: distance, depth: depth}, {:forward, val}),
    do: %{distance: distance + val, depth: depth}

  defp traverse([], result), do: result

  defp traverse([current | rest], result) do
    new_result =
      result
      |> move(current)

    traverse(rest, new_result)
  end

  def part1(list) do
    %{distance: distance, depth: depth} = traverse(list, %{distance: 0, depth: 0})
    distance * depth
  end

  def part2(list) do
    %{distance: distance, depth: depth} = traverse(list, %{distance: 0, depth: 0, aim: 0})
    distance * depth
  end

  def run do
    test_input =
      """
      forward 5
      down 5
      forward 8
      up 3
      down 8
      forward 2
      """
      |> parse

    input =
      Advent.daily_input("2021", "02")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
