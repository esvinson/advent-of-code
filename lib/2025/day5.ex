defmodule Aoc202505 do
  defp parse(input) do
    [fresh_raw, ingredients_raw] =
      input
      |> String.split("\n\n", trim: true)

    fresh =
      fresh_raw
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        [start, stop] =
          row
          |> String.split("-", trim: true)
          |> Enum.map(&String.to_integer/1)

        {start, stop}
      end)

    ingredients =
      ingredients_raw |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

    {fresh, ingredients}
  end

  defp part1({fresh, ingredients}) do
    fresh = Enum.map(fresh, fn {start, stop} -> Range.new(start, stop) end)

    Enum.reduce(ingredients, 0, fn ingredient, acc ->
      if Enum.any?(fresh, fn range -> ingredient in range end), do: acc + 1, else: acc
    end)
  end

  defp part2({fresh, _}) do
    {last, rest} =
      fresh
      |> Enum.sort()
      |> Enum.reduce({{0, 0}, []}, fn {start, stop}, {{pstart, pstop}, acc} ->
        if start >= pstart and start <= pstop and stop > pstop do
          {{pstart, stop}, acc}
        else
          if start >= pstart and start <= pstop and stop <= pstop do
            {{pstart, pstop}, acc}
          else
            {{start, stop}, [{pstart, pstop}] ++ acc}
          end
        end
      end)

    ([last] ++ rest)
    |> Enum.filter(fn
      {0, 0} -> false
      _ -> true
    end)
    |> Enum.map(fn {start, stop} -> stop - start + 1 end)
    |> Enum.sum()
  end

  def run() do
    test_input =
      """
      3-5
      10-14
      16-20
      12-18

      1
      5
      8
      11
      17
      32
      """
      |> parse()

    input =
      Advent.daily_input("2025", "05")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # Not 378661413228203
    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
