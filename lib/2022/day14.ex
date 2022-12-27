defmodule Aoc202214 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split(~r/[^\d]/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(4, 2, :discard)
    end)
  end

  def map_from_paths(paths) do
    paths
    |> Enum.reduce(MapSet.new(), fn path_row, acc ->
      path_row
      |> Enum.reduce(acc, fn [x1, y1, x2, y2], acc ->
        for x <- x1..x2, y <- y1..y2 do
          {x, y}
        end
        |> Enum.reduce(acc, fn pos, acc -> MapSet.put(acc, pos) end)
      end)
    end)
  end

  def drop_sand(_map, {_x, 1000}, grain), do: grain - 1

  def drop_sand(map, {x, y}, grain) do
    cond do
      not MapSet.member?(map, {x, y + 1}) -> drop_sand(map, {x, y + 1}, grain)
      not MapSet.member?(map, {x - 1, y + 1}) -> drop_sand(map, {x - 1, y + 1}, grain)
      not MapSet.member?(map, {x + 1, y + 1}) -> drop_sand(map, {x + 1, y + 1}, grain)
      true -> drop_sand(MapSet.put(map, {x, y}), {500, 0}, grain + 1)
    end
  end

  def part1(paths) do
    paths
    |> map_from_paths()
    |> drop_sand({500, 0}, 1)
  end

  def drop_sand2(map, {x, y}, grain, y),
    do: drop_sand2(MapSet.put(map, {x, y}), {500, 0}, grain, y)

  def drop_sand2(map, {x, y}, grain, max_depth) do
    cond do
      not MapSet.member?(map, {x, y + 1}) ->
        drop_sand2(map, {x, y + 1}, grain, max_depth)

      not MapSet.member?(map, {x - 1, y + 1}) ->
        drop_sand2(map, {x - 1, y + 1}, grain, max_depth)

      not MapSet.member?(map, {x + 1, y + 1}) ->
        drop_sand2(map, {x + 1, y + 1}, grain, max_depth)

      MapSet.member?(map, {500, 0}) ->
        grain - 1

      true ->
        drop_sand2(MapSet.put(map, {x, y}), {500, 0}, grain + 1, max_depth)
    end
  end

  def part2(paths) do
    max_y =
      paths |> map_from_paths() |> MapSet.to_list() |> Enum.map(fn {_, y} -> y end) |> Enum.max()

    paths
    |> map_from_paths()
    |> drop_sand2({500, 0}, 1, max_y + 2)
  end

  def run do
    test_input =
      """
      498,4 -> 498,6 -> 496,6
      503,4 -> 502,4 -> 502,9 -> 494,9
      """
      |> parse()

    input = Advent.daily_input("2022", "14") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
