defmodule Aoc202115 do
  def parse(input) do
    [first | _rest] =
      rows =
      input
      |> String.split("\n", trim: true)

    size = {String.length(first), length(rows)}

    map =
      rows
      |> Enum.reduce([], fn row, acc ->
        row =
          row
          |> String.split("", trim: true)
          |> Enum.map(&String.to_integer/1)

        acc ++ row
      end)

    {size, map}
  end

  def neighbors({maxx, maxy}, {x, y}) do
    for i <- -1..1,
        j <- -1..1,
        abs(i) != abs(j) and x + i >= 0 and x + i < maxx and y + j >= 0 and y + j < maxy and
          {i, j} != {0, 0},
        do: {x + i, y + j}
  end

  def build_output({{x, y}, map}) do
    map
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {value, key}, acc ->
      pos = {rem(key, x), div(key, y)}
      Map.put(acc, pos, {value, if({0, 0} == pos, do: 0, else: :infinity)})
    end)
  end

  def build_output2({{x, y}, map}) do
    repeats =
      for i <- 0..4, j <- 0..4 do
        {i, j}
      end

    # IO.inspect({x, y}, label: "====>")

    Enum.reduce(repeats, %{}, fn {i, j}, acc1 ->
      map
      |> Enum.with_index()
      |> Enum.reduce(acc1, fn {value, key}, acc2 ->
        pos = {rem(key, x) + i * x, div(key, y) + j * y}
        # |> IO.inspect()

        value = i + j + value
        value = if value > 9, do: value - 9, else: value
        Map.put(acc2, pos, {value, if({0, 0} == pos, do: 0, else: :infinity)})
      end)
    end)
  end

  def recurse(map, _size, []), do: map

  def recurse(map, size, [current | rest]) do
    {_cval, cshortest} = Map.get(map, current)
    n = neighbors(size, current)

    {map, new_queue} =
      Enum.reduce(n, {map, []}, fn pos, {map, new_queue} ->
        {nval, nshortest} = Map.get(map, pos)
        maybe_shortest = cshortest + nval

        if maybe_shortest < nshortest do
          {Map.put(map, pos, {nval, maybe_shortest}), [pos] ++ new_queue}
        else
          {map, new_queue}
        end
      end)

    recurse(map, size, rest ++ new_queue)
  end

  def part1({{x, y} = size, _} = input) do
    input
    |> build_output()
    |> recurse(size, [{0, 0}])
    |> Map.get({x - 1, y - 1})
    |> elem(1)
  end

  def part2({{x, y}, _} = input) do
    size = {x * 5, y * 5}

    input
    |> build_output2()
    |> recurse(size, [{0, 0}])
    |> Map.get({x * 5 - 1, y * 5 - 1})
    |> elem(1)
  end

  def run do
    test_input =
      """
      1163751742
      1381373672
      2136511328
      3694931569
      7463417111
      1319128137
      1359912421
      3125421639
      1293138521
      2311944581
      """
      |> parse()

    input = Advent.daily_input("2021", "15") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
