defmodule Aoc202506 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      vals = String.split(row, ~r{\s+}, trim: true)

      if String.match?(Enum.at(vals, 0), ~r{^\d+$}) do
        Enum.map(vals, &String.to_integer/1)
      else
        vals
      end
    end)
  end

  defp parse2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      vals = String.split(row, "", trim: true) |> Enum.reverse()

      Enum.map(vals, fn val ->
        if String.match?(val, ~r/^\d/), do: String.to_integer(val), else: val
      end)
    end)
    |> Enum.zip()
    |> Enum.map(fn row ->
      row
      |> Tuple.to_list()
      |> Enum.filter(fn x ->
        x != " "
      end)
    end)
  end

  defp calculate(["*" | rest]),
    do:
      Enum.reduce(rest, 1, fn val, acc ->
        val * acc
      end)

  defp calculate(["+" | rest]), do: Enum.sum(rest)

  defp part1(input) do
    input
    |> Enum.zip()
    |> Enum.map(fn problem ->
      problem
      |> Tuple.to_list()
      |> Enum.reverse()
      |> calculate()
    end)
    |> Enum.sum()
  end

  defp part2(cols) do
    {most, final} =
      Enum.reduce(cols, {[], []}, fn col, {acc, current} ->
        if col == [] do
          {[current] ++ acc, []}
        else
          if(Enum.any?(col, &is_binary/1)) do
            {oper, col} = List.pop_at(col, -1)
            {acc, [oper, Integer.undigits(col)] ++ current}
          else
            {acc, [Integer.undigits(col)] ++ current}
          end
        end
      end)

    ([final] ++ most)
    |> Enum.map(&calculate/1)
    |> Enum.sum()
  end

  def run() do
    test_input = "123 328  51 64 \n 45 64  387 23 \n  6 98  215 314\n*   +   *   +  "

    input =
      Advent.daily_input("2025", "06")

    IO.puts(
      "Test Answer Part 1 (4277556): #{inspect(part1(parse(test_input)), charlists: :as_lists)}"
    )

    IO.puts("Part 1: #{inspect(part1(parse(input)), charlists: :as_lists)}")

    IO.puts(
      "Test Answer Part 2 (3263827): #{inspect(part2(parse2(test_input)), charlists: :as_lists)}"
    )

    IO.puts("Part 2: #{inspect(part2(parse2(input)), charlists: :as_lists)}")
  end
end
