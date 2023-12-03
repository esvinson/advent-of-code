defmodule Aoc202303 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, index_y}, acc ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {col, index_x}, acc2 ->
        if col != ".", do: Map.put(acc2, {index_x, index_y}, col), else: acc2
      end)
    end)
  end

  defp point_sort({_x, y}, {_x2, y2}) when y > y2, do: false
  defp point_sort({_x, y}, {_x2, y2}) when y < y2, do: true
  defp point_sort({x, _y}, {x2, _y2}) when x > x2, do: false
  defp point_sort({x, _y}, {x2, _y2}) when x < x2, do: true
  defp point_sort(_, _), do: true

  defp adjacent_symbols(map, {x, y}) do
    for(
      i <- -1..1,
      j <- -1..1,
      x + i >= 0 and y + j >= 0 and {i, j} not in [{0, 0}] and Map.has_key?(map, {x + i, y + j}) and
        Regex.match?(~r/^[^\d]$/, Map.get(map, {x + i, y + j})),
      do: {x + i, y + j}
    )
  end

  # defp build_number(map, {x, y}) do
  #   # if Regex.match?(~r/^\d$/, Map.get(map, {x + 1, y})) do
  #   # Map.get()
  #   ""
  # end

  defp digit_to_left?(map, {x, y}), do: Regex.match?(~r/\d/, Map.get(map, {x - 1, y}, ""))
  defp digit_to_right?(map, {x, y}), do: Regex.match?(~r/\d/, Map.get(map, {x + 1, y}, ""))

  defp traverse([], _, _, output), do: output

  defp traverse([current | rest], map, has_symbol?, output) do
    if digit_to_left?(map, current) do
      # We will have handled all these from the first number in the string, skip
      traverse(rest, map, has_symbol?, output)
    else
      init = {current, Map.get(map, current), Map.get(has_symbol?, current)}

      {_, out_string, symbol?} =
        Enum.reduce_while(0..5, init, fn _, {{x2, y2} = pos, num_string, symbol?} ->
          if digit_to_right?(map, pos) do
            {:cont,
             {{x2 + 1, y2}, num_string <> Map.get(map, {x2 + 1, y2}),
              symbol? or Map.get(has_symbol?, {x2 + 1, y2})}}
          else
            {:halt, {pos, num_string, symbol?}}
          end
        end)

      traverse(
        rest,
        map,
        has_symbol?,
        [%{value: String.to_integer(out_string), symbol?: symbol?}] ++ output
      )
    end
  end

  defp build_numbers(map) do
    has_symbol? =
      map
      |> Map.keys()
      |> Enum.sort(&point_sort/2)
      |> Enum.reduce(%{}, fn pos, acc ->
        if Regex.match?(~r/^\d$/, Map.get(map, pos)) do
          Map.put(acc, pos, Enum.count(adjacent_symbols(map, pos)) > 0)
        else
          acc
        end
      end)

    has_symbol?
    |> Map.keys()
    |> Enum.sort(&point_sort/2)
    |> traverse(map, has_symbol?, [])
  end

  defp part1(mapped_input) do
    mapped_input
    |> build_numbers()
    |> Enum.filter(fn %{symbol?: symbol?} -> symbol? end)
    |> Enum.map(& &1[:value])
    |> Enum.sum()
  end

  # defp part2(mapped_input) do
  #   mapped_input
  # end

  def run() do
    test_input =
      """
      467..114..
      ...*......
      ..35..633.
      ......#...
      617*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
      """
      |> parse()

    input =
      Advent.daily_input("2023", "03")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
