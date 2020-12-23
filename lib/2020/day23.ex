defmodule Aoc202023 do
  def test_input, do: [3, 8, 9, 1, 2, 5, 4, 6, 7]

  def determine_destination(hand, 0, max), do: determine_destination(hand, max, max)

  def determine_destination(hand, n, max) do
    if Enum.member?(hand, n), do: determine_destination(hand, n - 1, max), else: n
  end

  def rebuild_rest(rest, destination, append) do
    Enum.reduce(rest, [], fn cup, acc ->
      if cup == destination do
        acc ++ [cup] ++ append
      else
        acc ++ [cup]
      end
    end)
  end

  def play(cups, _max, 0), do: cups

  def play([current, first, second, third | rest], max, rounds_left) do
    destination = determine_destination([first, second, third], current - 1, max)
    new_rest = rebuild_rest(rest, destination, [first, second, third])

    play(
      new_rest ++ [current],
      max,
      rounds_left - 1
    )
  end

  def part1(input, rounds) do
    max = Enum.max(input)

    [left, right] =
      play(input, max, rounds)
      |> Enum.join("")
      |> String.split("1")

    "#{right}#{left}"
  end

  def run do
    test_result1 = part1(test_input(), 10)
    IO.puts("Solution to Test Part 1 (10 rounds) (Should be 92658374): #{inspect(test_result1)}")
    test_result2 = part1(test_input(), 100)
    IO.puts("Solution to Test Part 1 (100 rounds) (Should be 67384529): #{inspect(test_result2)}")

    input = [8, 7, 1, 3, 6, 9, 4, 5, 2]
    result1 = part1(input, 100)
    IO.puts("Solution to Part 1: #{result1}")

    # result1 = part2(input)
    # IO.puts("Solution to Part 2: #{result1}")
  end
end
