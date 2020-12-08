defmodule Aoc202005 do
  defp test1, do: {"BFFFBBFRRR", 70, 7, 567}
  defp test2, do: {"FFFBBBFRRR", 14, 7, 119}
  defp test3, do: {"BBFFBBFRLL", 102, 4, 820}

  defp get_row(id) do
    id
    |> String.replace(~r/[RL]+/, "")
    |> String.replace("B", "1")
    |> String.replace("F", "0")
    |> String.to_integer(2)
  end

  defp get_col(id) do
    id
    |> String.replace(~r/[FB]+/, "")
    |> String.replace("R", "1")
    |> String.replace("L", "0")
    |> String.to_integer(2)
  end

  def test do
    [test1(), test2(), test3()]
    |> Enum.map(fn {id, row, column, seat} ->
      r = get_row(id)
      c = get_col(id)
      sid = r * 8 + c
      {row == r, column == c, sid == seat}
    end)
  end

  defp output_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
  end

  defp part1(list) do
    list
    |> Enum.map(fn id ->
      row = get_row(id)
      col = get_col(id)
      row * 8 + col
    end)
    |> Enum.max()
  end

  defp part2(list) do
    seats =
      list
      |> Enum.map(fn id ->
        row = get_row(id)
        col = get_col(id)
        row * 8 + col
      end)
      |> Enum.sort()

    min = Enum.min(seats)
    max = Enum.max(seats)

    Enum.reject(min..max, fn x -> Enum.member?(seats, x) end)
    |> List.first()
  end

  def run do
    list =
      Advent.daily_input("2020", "05")
      |> output_to_list()

    result1 = part1(list)
    IO.puts("Solution to Part 1: #{result1}")

    result2 = part2(list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
