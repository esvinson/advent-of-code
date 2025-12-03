defmodule Aoc202502 do
  defp parse(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.split(&1, "-", trim: true))
  end

  defp inrange(a, b, val) do
    range = Range.new(a, b)
    val in range
  end

  defp do_step(a, b, prefix, count) do
    val = String.to_integer("#{prefix}#{prefix}")

    if not inrange(a, b, val) && val > a do
      count
    else
      if val < a do
        do_step(a, b, prefix + 1, count)
      else
        do_step(a, b, prefix + 1, count + val)
      end
    end
  end

  defp check_ranges([a, b]) do
    lena = String.length(a)
    lenb = String.length(b)
    aval = String.to_integer(a)
    bval = String.to_integer(b)

    # if the number of digits is odd, and they are the same length it won't ever double twice, skip these
    if lena == lenb && Integer.mod(lena, 2) == 1 do
      0
    else
      a = if Integer.mod(lena, 2) == 1, do: Integer.to_string(Integer.pow(10, lena)), else: a
      lena = String.length(a)
      first = String.to_integer(String.slice(a, 0, Integer.floor_div(lena, 2)))
      do_step(aval, bval, first, 0)
    end
  end

  defp part1(ranges) do
    ranges
    |> Enum.map(&check_ranges/1)
    |> Enum.sum()
  end

  defp do_step2(a, b, prefix, prefix_len, length, result) do
    val =
      "#{prefix}"
      |> String.duplicate(Integer.floor_div(length, prefix_len))
      |> String.to_integer()

    if not inrange(a, b, val) && val > a do
      result
    else
      if val < a do
        do_step2(a, b, prefix + 1, prefix_len, length, result)
      else
        do_step2(a, b, prefix + 1, prefix_len, length, [val] ++ result)
      end
    end
  end

  defp check_ranges2([a, b]) do
    lena = max(String.length(a), 2)
    lenb = max(String.length(b), 2)
    aval = String.to_integer(a)
    bval = String.to_integer(b)

    halfa = Integer.floor_div(lena, 2)
    halfb = Integer.floor_div(lenb, 2)

    prefixesa =
      for i <- 1..halfa,
          Integer.mod(lena, i) == 0,
          do: {i, String.to_integer(String.slice(a, 0, i))}

    prefixesb =
      for i <- 1..halfb,
          Integer.mod(lenb, i) == 0,
          do: {i, Integer.pow(10, i - 1)}

    {a, b, lena, prefixesa, lenb, prefixesb} |> IO.inspect(charlists: :as_lists)

    if lena != lenb do
      Enum.map(prefixesa, fn {perfix_len, prefix} ->
        do_step2(
          aval,
          Integer.pow(10, String.length("#{aval}") + 1),
          prefix,
          perfix_len,
          lena,
          []
        )
      end) ++
        Enum.map(prefixesb, fn {perfix_len, prefix} ->
          do_step2(
            Integer.pow(10, String.length("#{bval}") - 1),
            bval,
            prefix,
            perfix_len,
            lenb,
            []
          )
        end)
    else
      Enum.map(prefixesa, fn {perfix_len, prefix} ->
        do_step2(aval, bval, prefix, perfix_len, lena, [])
      end)
    end
    |> List.flatten()
    # Dedupe only works properly on sorted lists
    |> Enum.sort()
    |> Enum.dedup()
    |> IO.inspect(label: "#{a}-#{b}:", charlists: :as_lists)
  end

  defp part2(ranges) do
    ranges
    |> Enum.map(&check_ranges2/1)
    |> List.flatten()
    |> Enum.sum()
  end

  def run() do
    test_input =
      "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
      |> parse()

    input =
      "17330-35281,9967849351-9967954114,880610-895941,942-1466,117855-209809,9427633930-9427769294,1-14,311209-533855,53851-100089,104-215,33317911-33385573,42384572-42481566,43-81,87864705-87898981,258952-303177,451399530-451565394,6464564339-6464748782,1493-2439,9941196-10054232,2994-8275,6275169-6423883,20-41,384-896,2525238272-2525279908,8884-16221,968909030-969019005,686256-831649,942986-986697,1437387916-1437426347,8897636-9031809,16048379-16225280"
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    # Not: 32955068316 (low)
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(parse("942-1466")), charlists: :as_lists)}")
    # Not 45947814543 (high), not 45763967685 (low)
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
