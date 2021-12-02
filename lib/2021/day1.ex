defmodule Aoc202101 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp traverse(_first, [], count), do: count

  defp traverse(first, rest, count) do
    [second | remaining] = rest

    new_count = if first < second, do: count + 1, else: count
    traverse(second, remaining, new_count)
  end

  def part1([first | rest]) do
    traverse(first, rest, 0)
  end

  defp traverse2(_first, [], result), do: result
  defp traverse2(_first, [_second], result), do: result

  defp traverse2(first, rest, result) do
    [second | remaining] = rest
    [third | _remaining2] = remaining

    new_result = result ++ [first + second + third]

    traverse2(second, remaining, new_result)
  end

  def part2([first | rest]) do
    [new_first | new_rest] = traverse2(first, rest, [])
    traverse(new_first, new_rest, 0)
  end

  def run do
    test_input =
      """
      199
      200
      208
      210
      200
      207
      240
      269
      260
      263
      """
      |> parse

    input =
      Advent.daily_input("2021", "01")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
