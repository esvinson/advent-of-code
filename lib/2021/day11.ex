defmodule Aoc202111 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
    |> List.to_tuple()
  end

  def value(map, {x, y}), do: elem(map, y * 10 + x)

  def neighbors({x, y}) do
    for i <- -1..1,
        j <- -1..1,
        x + i >= 0 and x + i < 10 and y + j >= 0 and y + j < 10 and {i, j} != {0, 0},
        do: {x + i, y + j}
  end

  defp initialize(map) do
    Enum.reduce(0..99, map, fn x, map ->
      put_in(map, [Access.elem(x)], {elem(map, x), false})
    end)
  end

  def step(_map, 0, count), do: count

  def step(map, n, old_count) do
    queue = for x <- 0..9, y <- 0..9, do: {x, y}

    {map, count} =
      map
      |> increment(queue)
      |> reset_and_count()

    step(map, n - 1, count + old_count)
  end

  defp reset_and_count(map) do
    Enum.reduce(0..99, {map, 0}, fn i, {map, count} ->
      {power, flashed} = elem(map, i)

      if flashed do
        new_map = put_in(map, [Access.elem(i)], {if(power >= 9, do: 0, else: power), false})

        {new_map, count + 1}
      else
        {map, count}
      end
    end)
  end

  def increment(map, []), do: map

  def increment(map, [{x, y} = position | queue]) do
    {power, flashed} = value(map, position)

    {new_queue, new_flash} =
      if power >= 9 and not flashed do
        {queue ++ neighbors(position), true}
      else
        {queue, flashed}
      end

    put_in(map, [Access.elem(y * 10 + x)], {power + 1, new_flash})
    |> increment(new_queue)
  end

  def part1(map) do
    map
    |> initialize()
    |> step(100, 0)
  end

  def part2(rows) do
    rows
  end

  def run do
    test_input =
      Advent.daily_input("2021", "11.test")
      |> parse()

    input =
      Advent.daily_input("2021", "11")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
