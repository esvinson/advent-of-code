defmodule Aoc202215 do
  def parse_sensor(sensor_string) do
    {:ok, regex} =
      "Sensor at x=(?<x>-?\\d+), y=(?<y>-?\\d+): closest beacon is at x=(?<beaconx>-?\\d+), y=(?<beacony>-?\\d+)"
      |> Regex.compile()

    regex
    |> Regex.named_captures(sensor_string)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn row, acc ->
      %{"x" => x, "y" => y, "beaconx" => bx, "beacony" => by} = parse_sensor(row)

      Map.put(
        acc,
        {String.to_integer(x), String.to_integer(y)},
        {String.to_integer(bx), String.to_integer(by)}
      )
    end)
  end

  def distance({x, y}, {bx, by}), do: abs(bx - x) + abs(by - y)

  def part1(sensors, check_y) do
    ranges =
      sensors
      |> Enum.map(fn {key, val} -> {key, distance(key, val)} end)
      |> Map.new()

    [{x, y}] = get_ranges(ranges, check_y)
    abs(x - y)
  end

  def combine_ranges([{x1, x2}]), do: [{x1, x2}]

  def combine_ranges([{x1, x2}, {x3, x4} | rest]) do
    cond do
      x2 + 1 < x3 -> [{x1, x2}] ++ combine_ranges([{x3, x4}] ++ rest)
      x2 >= x4 -> combine_ranges([{x1, x2}] ++ rest)
      true -> combine_ranges([{x1, x4}] ++ rest)
    end
  end

  def get_ranges(ranges, cur_y) do
    Enum.reduce(ranges, [], fn {{x, y}, dist}, acc ->
      remaining = dist - abs(y - cur_y)
      if remaining >= 0, do: [{x - remaining, x + remaining}] ++ acc, else: acc
    end)
    |> Enum.sort()
    |> combine_ranges()
  end

  def clamp([], _size), do: []

  def clamp([{x1, x2} | rest], size) do
    if x2 < 0 do
      clamp(rest, size)
    else
      if x1 > size do
        clamp(rest, size)
      else
        [{max(x1, 0), min(size, x2)}] ++ clamp(rest, size)
      end
    end
  end

  def part2(sensors, size) do
    ranges =
      sensors
      |> Enum.map(fn {key, val} -> {key, distance(key, val)} end)
      |> Map.new()

    Enum.reduce_while(0..size, nil, fn cur_y, _acc ->
      sets = get_ranges(ranges, cur_y) |> clamp(size)

      if length(sets) == 2 do
        [{_x1, x1}, {_x2, _x4}] = sets
        val = (x1 + 1) * 4_000_000 + cur_y
        {:halt, val}
      else
        {:cont, nil}
      end
    end)
  end

  def run do
    test_input =
      """
      Sensor at x=2, y=18: closest beacon is at x=-2, y=15
      Sensor at x=9, y=16: closest beacon is at x=10, y=16
      Sensor at x=13, y=2: closest beacon is at x=15, y=3
      Sensor at x=12, y=14: closest beacon is at x=10, y=16
      Sensor at x=10, y=20: closest beacon is at x=10, y=16
      Sensor at x=14, y=17: closest beacon is at x=10, y=16
      Sensor at x=8, y=7: closest beacon is at x=2, y=10
      Sensor at x=2, y=0: closest beacon is at x=2, y=10
      Sensor at x=0, y=11: closest beacon is at x=2, y=10
      Sensor at x=20, y=14: closest beacon is at x=25, y=17
      Sensor at x=17, y=20: closest beacon is at x=21, y=22
      Sensor at x=16, y=7: closest beacon is at x=15, y=3
      Sensor at x=14, y=3: closest beacon is at x=15, y=3
      Sensor at x=20, y=1: closest beacon is at x=15, y=3
      """
      |> parse()

    input = Advent.daily_input("2022", "15") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input, 10))}")
    IO.puts("Part 1: #{inspect(part1(input, 2_000_000))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input, 20))}")
    IO.puts("Part 2: #{inspect(part2(input, 4_000_000))}")
  end
end
