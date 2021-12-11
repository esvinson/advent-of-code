defmodule Aoc202109 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp neighbors({maxx, maxy}, {x, y}) do
    for i <- -1..1,
        j <- -1..1,
        abs(i) != abs(j) and x + i >= 0 and x + i <= maxx and y + j >= 0 and y + j <= maxy,
        do: {x + i, y + j}
  end

  def value(map, {x, y}), do: map |> elem(y) |> elem(x)

  def part1(list) do
    rows = Enum.count(list)
    cols = Enum.count(Enum.at(list, 0))
    max_cols = cols - 1
    max_rows = rows - 1

    map =
      list
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    for y <- 0..max_rows do
      for x <- 0..max_cols do
        {x, y}
      end
    end
    |> List.flatten()
    |> Enum.map(fn {x, y} ->
      cur_val = value(map, {x, y})

      neighbors({max_cols, max_rows}, {x, y})
      |> Enum.reduce_while(nil, fn {nx, ny}, _acc ->
        neighbor_val = value(map, {nx, ny})

        if neighbor_val > cur_val do
          {:cont, {true, cur_val}}
        else
          {:halt, false}
        end
      end)
    end)
    |> Enum.filter(fn
      false -> false
      _ -> true
    end)
    |> Enum.reduce(0, fn {true, x}, acc ->
      acc + x + 1
    end)
  end

  defp visited?(state, map, position),
    do: get_in(state, [Access.elem(0), position]) || value(map, position) == 9

  defp visit(state, {_x, _y} = position), do: put_in(state, [Access.elem(0), position], true)

  defp update_bucket({_, _, bucket} = state, {_x, _y} = position),
    do: put_in(state, [Access.elem(1), position], bucket)

  defp traverse(state, _map, _map_size, []), do: state

  defp traverse(state, map, map_size, [position | rest]) do
    if visited?(state, map, position) or value(map, position) == 9 do
      traverse(state, map, map_size, rest)
    else
      state =
        state
        |> visit(position)
        |> update_bucket(position)

      new_queue =
        map_size
        |> neighbors(position)
        |> Enum.filter(&(not visited?(state, map, &1)))
        |> case do
          [] -> rest
          neigh -> rest ++ neigh
        end

      traverse(state, map, map_size, new_queue)
    end
  end

  defp increment_bucket(state), do: update_in(state, [Access.elem(2)], &(&1 + 1))

  def part2(list) do
    rows = Enum.count(list)
    cols = Enum.count(Enum.at(list, 0))
    max_cols = cols - 1
    max_rows = rows - 1

    map =
      list
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    for y <- 0..max_rows do
      for x <- 0..max_cols do
        {x, y}
      end
    end
    |> List.flatten()
    |> Enum.reduce({_visited = %{}, _bucket_map = %{}, 0}, fn position, state ->
      if visited?(state, map, position) do
        state
      else
        traverse(state, map, {max_cols, max_rows}, [position])
        |> increment_bucket()
      end
    end)
    |> elem(1)
    |> Map.values()
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(fn v, v2 -> v2 < v end)
    |> Enum.take(3)
    |> Enum.reduce(1, fn x, acc -> acc * x end)
  end

  def run do
    test_input =
      """
      2199943210
      3987894921
      9856789892
      8767896789
      9899965678
      """
      |> parse()

    input =
      Advent.daily_input("2021", "09")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
