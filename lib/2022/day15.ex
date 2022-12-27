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

    beacons =
      Enum.reduce(sensors, MapSet.new(), fn {_key, beacon}, acc -> MapSet.put(acc, beacon) end)

    %{min: min, max: max, max_dist: max_dist} =
      Enum.reduce(ranges, %{min: :infinity, max: 0, max_dist: 0}, fn {{x, _y}, dist},
                                                                     %{
                                                                       min: min,
                                                                       max: max,
                                                                       max_dist: max_dist
                                                                     } ->
        min = if x < min, do: x, else: min
        max = if x > max, do: x, else: max

        max_dist = if dist > max_dist, do: dist, else: max_dist
        %{min: min, max: max, max_dist: max_dist}
      end)

    (min - max_dist)..(max + max_dist)
    |> Enum.reduce(MapSet.new(), fn x, total ->
      cur_pos = {x, check_y}

      Enum.reduce(ranges, total, fn {sensor, sensor_dist}, acc ->
        if distance(cur_pos, sensor) <= sensor_dist and not MapSet.member?(beacons, cur_pos) do
          MapSet.put(acc, cur_pos)
        else
          acc
        end
      end)
    end)
    |> MapSet.size()
  end

  def part2(sensors) do
    sensors
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
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
