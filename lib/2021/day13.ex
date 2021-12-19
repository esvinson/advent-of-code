defmodule Aoc202113 do
  def parse(input) do
    [dots, instructions] =
      input
      |> String.split("\n\n", trim: true)

    dots =
      dots
      |> String.split(["\n", ","], trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)
      |> MapSet.new()

    instructions =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.map(fn
        "fold along y=" <> y -> {:y, String.to_integer(y)}
        "fold along x=" <> x -> {:x, String.to_integer(x)}
      end)

    {instructions, dots}
  end

  def part1({instructions, dots}) do
    [first | _rest] = instructions

    Enum.reduce([first], dots, fn
      {:x, fold_x}, dots ->
        Enum.reduce(dots, MapSet.new(), fn {x, y}, acc ->
          MapSet.put(acc, {fold_x - abs(x - fold_x), y})
        end)

      {:y, fold_y}, dots ->
        Enum.reduce(dots, MapSet.new(), fn {x, y}, acc ->
          MapSet.put(acc, {x, fold_y - abs(y - fold_y)})
        end)
    end)
    |> MapSet.size()
  end

  def part2({instructions, dots}) do
    result =
      Enum.reduce(instructions, dots, fn
        {:x, fold_x}, dots ->
          Enum.reduce(dots, MapSet.new(), fn {x, y}, acc ->
            MapSet.put(acc, {fold_x - abs(x - fold_x), y})
          end)

        {:y, fold_y}, dots ->
          Enum.reduce(dots, MapSet.new(), fn {x, y}, acc ->
            MapSet.put(acc, {x, fold_y - abs(y - fold_y)})
          end)
      end)

    {maxx, _} = Enum.max_by(result, fn {x, _} -> x end)
    {_, maxy} = Enum.max_by(result, fn {_, y} -> y end)

    Enum.reduce(0..maxy, [], fn y, acc ->
      row =
        Enum.reduce(maxx..0, [], fn x, acc ->
          chr = if MapSet.member?(result, {x, y}), do: "#", else: " "
          [chr] ++ acc
        end)
        |> Enum.join("")

      acc ++ [row]
    end)
    |> Enum.join("\n")
    |> IO.puts()

    :ok
  end

  def run do
    test_input =
      Advent.daily_input("2021", "13.test")
      |> parse()

    input =
      Advent.daily_input("2021", "13")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
