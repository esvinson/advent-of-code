defmodule Aoc202114 do
  def parse(input) do
    [start | mapping] =
      input
      |> String.split("\n", trim: true)

    mapping =
      Enum.reduce(mapping, %{}, fn row, acc ->
        [key, value] =
          row
          |> String.split(" -> ", trim: true)

        Map.put(acc, key, value)
      end)

    {start, mapping}
  end

  defp run([[a, b] | rest], mapping, output) do
    val = Map.get(mapping, a <> b)
    run(rest, mapping, [b, val] ++ output)
  end

  defp run([], _mapping, output), do: output

  def part1({start, mapping}) do
    [first | _] =
      chain =
      start
      |> String.split("", trim: true)

    [a | rest] =
      Enum.reduce(0..9, chain, fn _, chain ->
        chain
        |> Enum.chunk_every(2, 1, :discard)
        |> run(mapping, [first])
        |> Enum.reverse()
        |> tap(&Enum.frequencies/1)
      end)
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)

    [b | _] = rest |> Enum.reverse()
    a - b
  end

  def part2({start, mapping}) do
    chain =
      start
      |> String.split("", trim: true)
      |> Enum.chunk_every(2, 1, ["0"])
      |> Enum.frequencies()

    # [a | rest] =
    {{_, min}, {_, max}} =
      Enum.reduce(0..39, chain, fn _, chain ->
        Enum.reduce(chain, %{}, fn {[a, b], count}, acc ->
          key = a <> b

          case mapping do
            %{^key => add} ->
              acc
              |> Map.update([a, add], count, &(&1 + count))
              |> Map.update([add, b], count, &(&1 + count))

            %{} ->
              Map.put(acc, [a, b], count)
          end
        end)
      end)
      |> Enum.reduce(%{}, fn {[a, _b], count}, acc ->
        Map.update(acc, a, count, &(&1 + count))
      end)
      |> Enum.min_max_by(fn {_, x} -> x end)

    max - min
  end

  def run do
    test_input =
      Advent.daily_input("2021", "14.test")
      |> parse()

    input =
      Advent.daily_input("2021", "14")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
