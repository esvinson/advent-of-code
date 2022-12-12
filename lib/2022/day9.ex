defmodule Aoc202209 do
  @up "U"
  @down "D"
  @left "L"
  @right "R"
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [direction, count_str] = String.split(row, " ", trim: true)
      {direction, String.to_integer(count_str)}
    end)
  end

  def move_head(@up, {hx, hy}), do: {hx, hy + 1}
  def move_head(@down, {hx, hy}), do: {hx, hy - 1}
  def move_head(@right, {hx, hy}), do: {hx + 1, hy}
  def move_head(@left, {hx, hy}), do: {hx - 1, hy}

  def maybe_move_tail({hx, hy}, {tx, ty}) when abs(hx - tx) < 2 and abs(hy - ty) < 2, do: {tx, ty}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx == tx and hy - ty > 1, do: {tx, ty + 1}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx == tx and hy - ty < -1, do: {tx, ty - 1}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx - tx > 1 and hy == ty, do: {tx + 1, ty}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx - tx < -1 and hy == ty, do: {tx - 1, ty}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx - tx < 0 and hy - ty < 0, do: {tx - 1, ty - 1}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx - tx < 0 and hy - ty > 0, do: {tx - 1, ty + 1}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx - tx > 0 and hy - ty < 0, do: {tx + 1, ty - 1}
  def maybe_move_tail({hx, hy}, {tx, ty}) when hx - tx > 0 and hy - ty > 0, do: {tx + 1, ty + 1}

  def run_moves([], _head, _tail, tail_visited), do: tail_visited

  def run_moves([{_direction, 0} | rest], head, tail, tail_visited),
    do: run_moves(rest, head, tail, tail_visited)

  def run_moves([{direction, moves} | rest], head, tail, tail_visited) do
    new_head = move_head(direction, head)
    new_tail = maybe_move_tail(new_head, tail)
    new_tail_visited = MapSet.put(tail_visited, new_tail)
    run_moves([{direction, moves - 1}] ++ rest, new_head, new_tail, new_tail_visited)
  end

  def part1(moves) do
    moves
    |> run_moves({0, 0}, {0, 0}, MapSet.new([{0, 0}]))
    |> MapSet.size()
  end

  def run_moves2([], _head, _tails, tail_visited), do: tail_visited

  def run_moves2([{_direction, 0} | rest], head, tails, tail_visited),
    do: run_moves2(rest, head, tails, tail_visited)

  def run_moves2([{direction, moves} | rest], head, tails, tail_visited) do
    new_head = move_head(direction, head)

    {new_tail, updated_tails} =
      tails
      |> Enum.reduce({new_head, []}, fn tail, {head, new_tails} ->
        new_tail = maybe_move_tail(head, tail)
        {new_tail, new_tails ++ [new_tail]}
      end)

    new_tail_visited = MapSet.put(tail_visited, new_tail)
    run_moves2([{direction, moves - 1}] ++ rest, new_head, updated_tails, new_tail_visited)
  end

  def part2(moves) do
    moves
    |> run_moves2(
      {0, 0},
      [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
      MapSet.new([{0, 0}])
    )
    |> MapSet.size()
  end

  def run do
    test_input =
      """
      R 4
      U 4
      L 3
      D 1
      R 4
      D 1
      L 5
      R 2
      """
      |> parse()

    test_input2 =
      """
      R 5
      U 8
      L 8
      D 3
      R 17
      D 10
      L 25
      U 20
      """
      |> parse()

    input = Advent.daily_input("2022", "09") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Test Answer Part 2 (larger): #{inspect(part2(test_input2))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
