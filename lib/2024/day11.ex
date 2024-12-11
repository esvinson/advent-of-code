defmodule Aoc202411 do
  defp parse(input) do
    input
    |> String.split(" ", trim: true)
  end

  defp mapify([], result), do: result

  defp mapify([val | rest], result) do
    new_result = Map.update(result, val, 1, fn x -> x + 1 end)
    mapify(rest, new_result)
  end

  defp iterate(items, 0), do: items

  defp iterate(items, count) do
    Enum.reduce(items, %{}, fn {k, v}, acc ->
      len = String.length(k)

      cond do
        k == "0" ->
          Map.update(acc, "1", v, fn x -> x + v end)

        rem(len, 2) == 0 ->
          {k1, k2} = String.split_at(k, div(len, 2))
          k1 = k1 |> String.to_integer() |> to_string
          k2 = k2 |> String.to_integer() |> to_string

          acc
          |> Map.update(k1, v, fn x -> x + v end)
          |> Map.update(k2, v, fn x -> x + v end)

        true ->
          key = to_string(String.to_integer(k) * 2024)
          Map.update(acc, key, v, fn x -> x + v end)
      end
    end)
    |> iterate(count - 1)
  end

  defp domath(items) do
    Enum.reduce(items, 0, fn {_k, v}, acc ->
      acc + v
    end)
  end

  defp part1(input, count \\ 25)

  defp part1(input, count) do
    input
    |> mapify(%{})
    |> iterate(count)
    |> domath()
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input = parse("125 17")

    input = parse("92 0 286041 8034 34394 795 8 2051489")

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    IO.puts("Part 2: #{inspect(part1(input, 75), charlists: :as_lists)}")
  end
end
