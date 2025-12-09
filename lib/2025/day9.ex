defmodule Aoc202509 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [x, y] = String.split(row, ",", trim: true)
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  defp distance({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
  end

  defp build_list([]), do: []

  defp build_list([first | points]) do
    Enum.map(points, fn point ->
      {distance(first, point), first, point}
    end)
    |> Kernel.++(build_list(points))
  end

  defp part1(points) do
    [{max_area, _, _}] =
      build_list(points)
      |> Enum.sort(:desc)
      |> Enum.take(1)

    max_area
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      7,1
      11,1
      11,7
      9,7
      9,5
      2,5
      2,3
      7,3
      """
      |> parse()

    input =
      Advent.daily_input("2025", "09")
      |> parse()

    IO.puts("Test Answer Part 1 (50): #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
