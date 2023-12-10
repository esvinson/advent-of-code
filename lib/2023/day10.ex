defmodule Aoc202310 do
  defp parse(input) do
    rows =
      input
      |> String.split("\n", trim: true)

    row_count = length(rows)
    col_count = List.first(rows) |> String.split("", trim: true) |> Enum.count()

    {start, mapped} =
      rows
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

    {{col_count, row_count}, start, mapped}
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

  defp part1({_size, start, mapping}) do
    start
    |> move_through_pipe(mapping, MapSet.new())
    |> MapSet.size()
    |> div(2)
  end

  defp count_left({-1, _y}, _mapping, _path, _size, _last_edge), do: 0

  defp count_left({x, y} = current, mapping, path, size, last_edge) do
    type = Map.get(mapping, current)

    {new_edge, val} =
      if MapSet.member?(path, current) do
        case {type, last_edge} do
          {%{left: true, right: true, up: false, down: false}, last_edge} ->
            {last_edge, 0}

          {%{left: false, right: false, up: true, down: true}, _last_edge} ->
            {nil, 1}

          {type, nil} ->
            {type, 1}

          # L7 = 1
          # FJ = 1
          # LJ = 2
          # F7 = 2

          {%{right: true, up: true}, %{left: true, down: true}} ->
            {nil, 0}

          {%{right: true, down: true}, %{left: true, up: true}} ->
            {nil, 0}

          {%{right: true, up: true}, %{left: true, up: true}} ->
            {nil, 1}

          {%{right: true, down: true}, %{left: true, down: true}} ->
            {nil, 1}
        end
      else
        {last_edge, 0}
      end

    val + count_left({x - 1, y}, mapping, path, size, new_edge)
  end

  defp overwrite_start(mapping, start) do
    new_val =
      start
      |> adjacent()
      |> Enum.reduce([], fn {offset, next}, directions ->
        direction =
          case offset do
            {0, -1} -> :up
            {0, 1} -> :down
            {-1, 0} -> :left
            {1, 0} -> :right
          end

        if can_move?(direction, Map.get(mapping, start), Map.get(mapping, next, map("."))) do
          [direction] ++ directions
        else
          directions
        end
      end)
      |> Enum.sort()
      |> case do
        [:down, :up] -> map("|")
        [:left, :right] -> map("-")
        [:left, :up] -> map("J")
        [:right, :up] -> map("L")
        [:down, :right] -> map("F")
        [:down, :left] -> map("7")
      end

    Map.put(mapping, start, new_val)
  end

  defp part2({size, start, mapping}) do
    path_tiles =
      start
      |> move_through_pipe(mapping, MapSet.new())

    mapping = overwrite_start(mapping, start)

    mapping
    |> Map.keys()
    |> Enum.reduce(0, fn current, acc ->
      path_tiles
      |> MapSet.member?(current)
      |> case do
        false ->
          left = count_left(current, mapping, path_tiles, size, nil)

          if left > 0 and rem(left, 2) == 1,
            do: acc + 1,
            else: acc

        _ ->
          acc
      end
    end)
  end

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

    test_input3 =
      """
      ...........
      .S-------7.
      .|F-----7|.
      .||.....||.
      .||.....||.
      .|L-7.F-J|.
      .|..|.|..|.
      .L--J.L--J.
      ...........
      """
      |> parse()

    test_input4 =
      """
      ..........
      .S------7.
      .|F----7|.
      .||....||.
      .||....||.
      .|L-7F-J|.
      .|..||..|.
      .L--JL--J.
      ..........
      """
      |> parse()

    test_input5 =
      """
      FF7FSF7F7F7F7F7F---7
      L|LJ||||||||||||F--J
      FL-7LJLJ||||||LJL-77
      F--JF--7||LJLJ7F7FJ-
      L---JF-JLJ.||-FJLJJ7
      |F|F-JF---7F7-L7L|7|
      |FFJF7L7F-JF7|JL---7
      7-L-JL7||F7|L7F-7F7|
      L.L7LFJ|||||FJL7||LJ
      L7JLJL-JLJLJL--JLJ.L
      """
      |> parse()

    input =
      Advent.daily_input("2023", "10")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input1))}")
    IO.puts("Test Answer Part 1: #{inspect(part1(test_input2))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input3))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input4))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input5))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
