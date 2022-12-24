defmodule Aoc202212 do
  def parse(input) do
    rows =
      input
      |> String.split("\n", trim: true)

    rows
    |> Enum.map(&String.to_charlist/1)
    |> Enum.with_index()
    |> Enum.reduce(%{start: nil, stop: nil, map: %{}}, fn {row, y}, acc ->
      acc = Map.put_new(acc, :size, {length(row), length(rows)})

      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {val, x}, %{map: map} = acc ->
        # 69 = E, 83 = S
        acc = if val == 83, do: Map.put(acc, :start, {x, y}), else: acc
        acc = if val == 69, do: Map.put(acc, :stop, {x, y}), else: acc
        val = if val == 83, do: 97, else: val
        val = if val == 69, do: 122, else: val

        acc
        |> Map.put(:map, Map.put(map, {x, y}, val - 97))
      end)
    end)
  end

  def movements({x, y}, {sizex, sizey}),
    do:
      for(
        i <- -1..1,
        j <- -1..1,
        x + i >= 0 and y + j >= 0 and x + i < sizex and y + j < sizey and abs(i) != abs(j),
        do: {x + i, y + j}
      )

  def can_move?(current, nextval) when nextval - current > 1, do: false
  def can_move?(_current, _nextval), do: true

  def find_end(_map, _size, _stop, [], _visited), do: :no_path
  def find_end(_map, _size, stop, [{stop, distance} | _queue], _visited), do: distance

  def find_end(map, size, stop, [{current, distance} | queue], visited) do
    add_queue =
      if MapSet.member?(visited, current) do
        []
      else
        movements(current, size)
        |> Enum.filter(&can_move?(Map.get(map, current), Map.get(map, &1)))
        |> Enum.reject(&MapSet.member?(visited, &1))
        |> Enum.map(fn pos -> {pos, distance + 1} end)
      end

    find_end(map, size, stop, queue ++ add_queue, MapSet.put(visited, current))
  end

  def part1(%{map: map, start: start, stop: stop, size: size}) do
    queue =
      movements(start, size)
      |> Enum.filter(&can_move?(Map.get(map, start), Map.get(map, &1)))
      |> Enum.map(fn pos -> {pos, 1} end)

    find_end(map, size, stop, queue, MapSet.new([start]))
  end

  def part2(%{map: map, stop: stop, size: size}) do
    starts =
      Enum.reduce(map, [], fn {pos, val}, acc ->
        if val == 0, do: [pos] ++ acc, else: acc
      end)

    Enum.map(starts, fn start ->
      queue =
        movements(start, size)
        |> Enum.filter(&can_move?(Map.get(map, start), Map.get(map, &1)))
        |> Enum.map(fn pos -> {pos, 1} end)

      find_end(map, size, stop, queue, MapSet.new([start]))
    end)
    |> Enum.reject(&(&1 == :no_path))
    |> Enum.min()
  end

  def run do
    test_input =
      """
      Sabqponm
      abcryxxl
      accszExk
      acctuvwj
      abdefghi
      """
      |> parse()

    input = Advent.daily_input("2022", "12") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
