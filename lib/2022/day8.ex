defmodule Aoc202208 do
  def parse(input) do
    rows =
      input
      |> String.split("\n", trim: true)

    rows
    |> Enum.with_index()
    |> Enum.reduce(%{rows: 0, cols: 0, map: %{}}, fn {str, row}, acc ->
      cols =
        str
        |> String.split("", trim: true)
        |> Enum.map(&String.to_integer/1)

      cols
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {val, col}, acc2 ->
        acc2 =
          if row == 0 and col == 0 do
            acc2
            |> Map.put(:rows, length(rows))
            |> Map.put(:cols, length(cols))
          else
            acc2
          end

        key = {col, row}
        new_map = Map.put(acc2.map, key, val)
        Map.put(acc2, :map, new_map)
      end)
    end)
  end

  def visible_from_edge?([], _map, _current_value), do: true

  def visible_from_edge?([visit | rest], map, current_value) do
    new_value = Map.get(map, visit)

    if new_value >= current_value do
      false
    else
      visible_from_edge?(rest, map, current_value)
    end
  end

  def is_visible?({0, _}, _size, _map), do: true
  def is_visible?({_, 0}, _size, _map), do: true
  def is_visible?({x, y}, {cols, rows}, _map) when x == cols - 1 or y == rows - 1, do: true

  def is_visible?({x, y}, {cols, rows}, map) do
    current_value = Map.get(map, {x, y})

    visit_left = for i <- 0..(x - 1), do: {i, y}
    visit_right = for i <- (x + 1)..(cols - 1), do: {i, y}
    visit_up = for j <- 0..(y - 1), do: {x, j}
    visit_down = for j <- (y + 1)..(rows - 1), do: {x, j}

    if visible_from_edge?(visit_left, map, current_value) or
         visible_from_edge?(visit_right, map, current_value) or
         visible_from_edge?(visit_up, map, current_value) or
         visible_from_edge?(visit_down, map, current_value) do
      true
    else
      false
    end
  end

  def do_it([], _size, _map, result), do: result

  def do_it([{x, y} | queue], size, map, result) do
    if is_visible?({x, y}, size, map) do
      do_it(queue, size, map, [{x, y}] ++ result)
    else
      do_it(queue, size, map, result)
    end
  end

  def part1(%{rows: rows, cols: cols, map: map}) do
    positions =
      for x <- 0..(cols - 1),
          y <- 0..(rows - 1),
          do: {x, y}

    positions
    |> do_it({cols, rows}, map, [])
    |> Enum.count()
  end

  def view_score([], _map, _current_value, trees), do: trees

  def view_score([visit | rest], map, current_value, trees) do
    new_value = Map.get(map, visit)

    if new_value >= current_value do
      trees + 1
    else
      view_score(rest, map, current_value, trees + 1)
    end
  end

  def calculate_score({x, y}, {cols, rows}, map) do
    current_value = Map.get(map, {x, y})

    visit_left = for i <- (x - 1)..0, do: {i, y}
    visit_right = for i <- (x + 1)..(cols - 1), do: {i, y}
    visit_up = for j <- (y - 1)..0, do: {x, j}
    visit_down = for j <- (y + 1)..(rows - 1), do: {x, j}

    view_score(visit_left, map, current_value, 0) * view_score(visit_right, map, current_value, 0) *
      view_score(visit_up, map, current_value, 0) * view_score(visit_down, map, current_value, 0)
  end

  def do_it2([], _size, _map, result), do: result

  def do_it2([{x, y} | queue], size, map, result) do
    score = calculate_score({x, y}, size, map)

    do_it2(queue, size, map, [score] ++ result)
  end

  def part2(%{rows: rows, cols: cols, map: map}) do
    # Edges aren't necessary to check because anything x 0 is 0.
    positions =
      for x <- 1..(cols - 2),
          y <- 1..(rows - 2),
          do: {x, y}

    positions
    |> do_it2({cols, rows}, map, [])
    |> Enum.max()
  end

  def run do
    test_input =
      """
      30373
      25512
      65332
      33549
      35390
      """
      |> parse()

    input = Advent.daily_input("2022", "08") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
