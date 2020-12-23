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

  def output_part1(cups, id \\ 1) do
    cups
    |> Map.get(id)
    |> case do
      1 -> []
      cup_id -> [cup_id | output_part1(cups, cup_id)]
    end
  end

  def output_part2(cups) do
    first = Map.get(cups, 1)
    second = Map.get(cups, first)
    first * second
  end

  def play(cups, _current, _max, 0), do: cups

  def play(cups, current, max, rounds_left) do
    first = Map.get(cups, current)
    second = Map.get(cups, first)
    third = Map.get(cups, second)
    next = Map.get(cups, third)

    destination = determine_destination([first, second, third], current - 1, max)
    destination_next = Map.get(cups, destination)

    cups
    |> Map.put(current, next)
    |> Map.put(destination, first)
    |> Map.put(third, destination_next)
    |> play(
      next,
      max,
      rounds_left - 1
    )
  end

  def build_map(list, output \\ %{}, first \\ nil)
  def build_map([current | _rest] = list, output, nil), do: build_map(list, output, current)
  # One element left
  def build_map([current], output, first) do
    Map.put(output, current, first)
  end

  def build_map([current, next | rest], output, first) do
    build_map([next | rest], Map.put(output, current, next), first)
  end

  def part1([first | _rest] = input, rounds) do
    max = Enum.max(input)
    cups = build_map(input)

    play(cups, first, max, rounds)
    |> output_part1(1)
    |> Enum.join()
  end

  def part2([first | _rest] = input) do
    max = Enum.max(input)
    cups = build_map(input ++ Enum.to_list((max + 1)..1_000_000))

    play(cups, first, 1_000_000, 10_000_000)
    |> output_part2()
  end

  def run do
    test_result1 = part1(test_input(), 10)
    IO.puts("Solution to Test Part 1 (10 rounds) (Should be 92658374): #{inspect(test_result1)}")
    test_result2 = part1(test_input(), 100)
    IO.puts("Solution to Test Part 1 (100 rounds) (Should be 67384529): #{inspect(test_result2)}")

    input = [8, 7, 1, 3, 6, 9, 4, 5, 2]
    result1 = part1(input, 100)
    IO.puts("Solution to Part 1: #{result1}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
