defmodule Aoc202507 do
  import Bitwise

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  defp tree_to_binary(tree) do
    [start | rest] =
      tree
      |> Enum.filter(fn line -> not String.match?(line, ~r{^\.+$}) end)
      |> Enum.map(fn line ->
        {val, ""} =
          line
          |> String.split("", trim: true)
          |> Enum.map(fn
            "." -> 0
            "S" -> 1
            "^" -> 1
            _ -> 0
          end)
          |> Enum.join("")
          |> Integer.parse(2)

        val
      end)

    {start, rest}
  end

  defp count_bits(0), do: 0

  defp count_bits(n) when is_integer(n) and n > 0 do
    (n &&& 1) + count_bits(n >>> 1)
  end

  defp part1(tree) do
    {start, rest} = tree_to_binary(tree)

    {count, _beams} =
      Enum.reduce(rest, {0, start}, fn row, {count, beams} ->
        hits = band(beams, row)
        hit_count = count_bits(hits)
        new_beams = bor(hits <<< 1, hits >>> 1)
        {count + hit_count, bor(bxor(beams, hits), new_beams)}
      end)

    count
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      .......S.......
      ...............
      .......^.......
      ...............
      ......^.^......
      ...............
      .....^.^.^.....
      ...............
      ....^.^...^....
      ...............
      ...^.^...^.^...
      ...............
      ..^...^.....^..
      ...............
      .^.^.^.^.^...^.
      ...............
      """
      |> parse()

    input =
      Advent.daily_input("2025", "07")
      |> parse()

    IO.puts("Test Answer Part 1 (21): #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
