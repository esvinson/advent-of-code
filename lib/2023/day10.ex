defmodule Aoc202310 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({nil, %{}}, fn {row, yindex}, {start, mapped} ->
      cols =
        row
        |> String.split("", trim: true)

      start =
        if is_nil(start),
          do:
            cols
            |> Enum.with_index()
            |> Enum.reduce(nil, fn {val, xindex}, acc ->
              if val == "S", do: {xindex, yindex}, else: acc
            end),
          else: start

      mapped =
        cols
        |> Enum.map(&map/1)
        |> Enum.with_index()
        |> Enum.reduce(mapped, fn {col, xindex}, cols ->
          Map.put(cols, {xindex, yindex}, col)
        end)

      {start, mapped}
    end)
  end

  def map("|"), do: %{left: false, right: false, up: true, down: true}
  def map("-"), do: %{left: true, right: true, up: false, down: false}
  def map("F"), do: %{left: false, right: true, up: false, down: true}
  def map("7"), do: %{left: true, right: false, up: false, down: true}
  def map("L"), do: %{left: false, right: true, up: true, down: false}
  def map("J"), do: %{left: true, right: false, up: true, down: false}
  def map("S"), do: %{left: true, right: true, up: true, down: true}
  def map("."), do: %{left: false, right: false, up: false, down: false}

  defp can_move?(:up, %{up: true} = _source, %{down: true} = _destination), do: true
  defp can_move?(:down, %{down: true} = _source, %{up: true} = _destination), do: true
  defp can_move?(:left, %{left: true} = _source, %{right: true} = _destination), do: true
  defp can_move?(:right, %{right: true} = _source, %{left: true} = _destination), do: true
  defp can_move?(_direction, _source, _destination), do: false

  defp adjacent({x, y}) do
    for i <- -1..1,
        j <- -1..1,
        {i, j} != {0, 0} and (i == 0 or j == 0),
        do: {{i, j}, {x + i, y + j}}
  end

  defp move_through_pipe(current, mapping, visited) do
    visited = MapSet.put(visited, current)

    current
    |> adjacent()
    |> Enum.reduce(visited, fn {offset, next}, visited ->
      direction =
        case offset do
          {0, -1} -> :up
          {0, 1} -> :down
          {-1, 0} -> :left
          {1, 0} -> :right
        end

      if can_move?(direction, Map.get(mapping, current), Map.get(mapping, next, map("."))) and
           not MapSet.member?(visited, next) do
        move_through_pipe(next, mapping, visited)
      else
        visited
      end
    end)
  end

  defp part1({start, mapping}) do
    start
    |> move_through_pipe(mapping, MapSet.new())
    |> MapSet.size()
    |> div(2)
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input1 =
      """
      .....
      .S-7.
      .|.|.
      .L-J.
      .....
      """
      |> parse()

    test_input2 =
      """
      ..F7.
      .FJ|.
      SJ.L7
      |F--J
      LJ...
      """
      |> parse()

    input =
      Advent.daily_input("2023", "10")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input1))}")
    IO.puts("Test Answer Part 1: #{inspect(part1(test_input2))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
