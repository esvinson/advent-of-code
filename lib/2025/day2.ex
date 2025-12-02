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

  # defp part2(input) do
  #   input
  # end

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
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
