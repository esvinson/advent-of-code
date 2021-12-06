defmodule Aoc202105 do
  def parse(input) do
    input
    |> String.split([" ", "-", ">", ",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(4)
    |> Enum.map(&List.to_tuple/1)
  end

  def part1(steps) do
    steps
    # Only horizontal and vertical movement
    |> Enum.filter(fn
      {num, _, num, _} -> true
      {_, num, _, num} -> true
      _ -> false
    end)
    |> Enum.reduce(%{}, fn
      {x, y1, x, y2}, acc ->
        Enum.reduce(y1..y2, acc, fn i, acc2 ->
          Map.update(acc2, {x, i}, 1, fn val -> val + 1 end)
        end)

      {x1, y, x2, y}, acc ->
        Enum.reduce(x1..x2, acc, fn i, acc2 ->
          Map.update(acc2, {i, y}, 1, fn val -> val + 1 end)
        end)
    end)
    |> Map.values()
    |> Enum.filter(fn x -> x > 1 end)
    |> Enum.count()
  end

  def part2(steps) do
    steps
    # Only horizontal and vertical movement
    |> Enum.filter(fn
      {num, _, num, _} -> true
      {_, num, _, num} -> true
      {x1, y1, x2, y2} when abs(x1 - x2) == abs(y1 - y2) -> true
      _ -> false
    end)
    |> Enum.reduce(%{}, fn
      {x, y1, x, y2}, acc ->
        Enum.reduce(y1..y2, acc, fn i, acc2 ->
          Map.update(acc2, {x, i}, 1, fn val -> val + 1 end)
        end)

      {x1, y, x2, y}, acc ->
        Enum.reduce(x1..x2, acc, fn i, acc2 ->
          Map.update(acc2, {i, y}, 1, fn val -> val + 1 end)
        end)

      {x1, y1, x2, y2}, acc ->
        distance = abs(x2 - x1)

        0..distance
        |> Enum.reduce(acc, fn i, acc2 ->
          new_x = if x1 > x2, do: x1 - i, else: x1 + i
          new_y = if y1 > y2, do: y1 - i, else: y1 + i
          Map.update(acc2, {new_x, new_y}, 1, fn val -> val + 1 end)
        end)
    end)
    |> Map.values()
    |> Enum.filter(fn x -> x > 1 end)
    |> Enum.count()
  end

  def run do
    test_input = Advent.daily_input("2021", "05.test") |> parse()

    input =
      Advent.daily_input("2021", "05")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
