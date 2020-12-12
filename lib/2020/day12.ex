defmodule Aoc202012 do
  def test_input,
    do: """
    F10
    N3
    F7
    R90
    F11
    """

  defp translate("N"), do: :north
  defp translate("S"), do: :south
  defp translate("E"), do: :east
  defp translate("W"), do: :west
  defp translate("F"), do: :forward
  defp translate("R"), do: :right
  defp translate("L"), do: :left

  def input_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [direction, distance] = String.split(row, "", parts: 2, trim: true)
      %{direction: translate(direction), distance: String.to_integer(distance)}
    end)
  end

  defp rotate(:right, :north, 90), do: :east
  defp rotate(:right, :north, 180), do: :south
  defp rotate(:right, :north, 270), do: :west
  defp rotate(:right, :east, 90), do: :south
  defp rotate(:right, :east, 180), do: :west
  defp rotate(:right, :east, 270), do: :north
  defp rotate(:right, :south, 90), do: :west
  defp rotate(:right, :south, 180), do: :north
  defp rotate(:right, :south, 270), do: :east
  defp rotate(:right, :west, 90), do: :north
  defp rotate(:right, :west, 180), do: :east
  defp rotate(:right, :west, 270), do: :south

  defp rotate(:left, :north, 90), do: :west
  defp rotate(:left, :north, 180), do: :south
  defp rotate(:left, :north, 270), do: :east
  defp rotate(:left, :east, 90), do: :north
  defp rotate(:left, :east, 180), do: :west
  defp rotate(:left, :east, 270), do: :south
  defp rotate(:left, :south, 90), do: :east
  defp rotate(:left, :south, 180), do: :north
  defp rotate(:left, :south, 270), do: :west
  defp rotate(:left, :west, 90), do: :south
  defp rotate(:left, :west, 180), do: :east
  defp rotate(:left, :west, 270), do: :north

  defp do_move(x, y, :north, distance, facing), do: {x, y + distance, facing}
  defp do_move(x, y, :east, distance, facing), do: {x + distance, y, facing}
  defp do_move(x, y, :south, distance, facing), do: {x, y - distance, facing}
  defp do_move(x, y, :west, distance, facing), do: {x - distance, y, facing}

  defp move({x, y, facing}, %{direction: direction, distance: distance})
       when direction in [:north, :east, :south, :west],
       do: do_move(x, y, direction, distance, facing)

  defp move({x, y, facing}, %{direction: direction, distance: distance})
       when direction in [:left, :right],
       do: {x, y, rotate(direction, facing, distance)}

  defp move({x, y, facing}, %{direction: :forward, distance: distance}),
    do: do_move(x, y, facing, distance, facing)

  def part1(list) do
    {x, y, _facing} =
      list
      |> Enum.reduce({0, 0, :east}, fn movement, acc ->
        move(acc, movement)
      end)

    abs(x) + abs(y)
  end

  def part2(_list) do
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_list()

    input =
      Advent.daily_input("2020", "12")
      |> input_to_list()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 25): #{test_result1}")

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2 = part2(test_input1)
    IO.puts("Solution to Test Part 2 (Should be 26): #{test_result2}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
