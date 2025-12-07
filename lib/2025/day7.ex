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

  defp calc_beam_start(0, _offset, map), do: map

  defp calc_beam_start(beams, offset, map) do
    x = beams &&& 1

    if x > 0 do
      new_map = Map.put(map, offset, 1)
      calc_beam_start(beams >>> 1, offset + 1, new_map)
    else
      calc_beam_start(beams >>> 1, offset + 1, map)
    end
  end

  defp calc_beams_left(0, _offset, map), do: map

  defp calc_beams_left(beams, offset, map) do
    x = beams &&& 1

    if x > 0 do
      current = Map.get(map, offset, 0)
      source = Map.get(map, offset - 1, 0)
      new_map = Map.put(map, offset, current + source)
      calc_beams_left(beams >>> 1, offset + 1, new_map)
    else
      calc_beams_left(beams >>> 1, offset + 1, map)
    end
  end

  defp calc_beams_right(0, _offset, map), do: map

  defp calc_beams_right(beams, offset, map) do
    x = beams &&& 1

    if x > 0 do
      current = Map.get(map, offset, 0)
      source = Map.get(map, offset + 1, 0)
      new_map = Map.put(map, offset, current + source)
      calc_beams_right(beams >>> 1, offset + 1, new_map)
    else
      calc_beams_right(beams >>> 1, offset + 1, map)
    end
  end

  defp clear_hit_beams(0, _offset, map), do: map

  defp clear_hit_beams(beams, offset, map) do
    x = beams &&& 1

    if x > 0 do
      clear_hit_beams(beams >>> 1, offset + 1, Map.put(map, offset, 0))
    else
      clear_hit_beams(beams >>> 1, offset + 1, map)
    end
  end

  defp traverse(0, _, _), do: 0
  defp traverse(_beams, [], map), do: Enum.sum(Map.values(map))

  defp traverse(beams, [row | rest], map) do
    hits = band(beams, row)
    left_beams = hits <<< 1
    right_beams = hits >>> 1
    map = calc_beams_left(left_beams, 0, map)
    map = calc_beams_right(right_beams, 0, map)
    map = clear_hit_beams(hits, 0, map)
    new_beams = bor(bxor(beams, hits), bor(hits <<< 1, hits >>> 1))

    traverse(new_beams, rest, map)
  end

  defp part2(tree) do
    {start, rest} = tree_to_binary(tree)

    traverse(start, rest, calc_beam_start(start, 0, %{}))
  end

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
    IO.puts("Test Answer Part 2 (40): #{inspect(part2(test_input), charlists: :as_lists)}")
    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
