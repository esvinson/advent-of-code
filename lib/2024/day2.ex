defmodule Aoc202402 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp in_order?(numbers) do
    cond do
      numbers == Enum.sort(numbers) -> true
      numbers == Enum.sort(numbers, :desc) -> true
      true -> false
    end
  end

  defp has_duplicates?(numbers) do
    max_val =
      numbers
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.max()

    max_val > 1
  end

  defp safe_level_change?([_a]), do: true

  defp safe_level_change?([a, b | rest]) do
    if abs(b - a) > 3, do: false, else: safe_level_change?([b] ++ rest)
  end

  defp is_safe?(numbers) do
    with true <- in_order?(numbers),
         false <- has_duplicates?(numbers),
         true <- safe_level_change?(numbers) do
      true
    else
      _ -> false
    end
  end

  defp part1(input) do
    input
    |> Enum.map(&is_safe?/1)
    |> Enum.reduce(0, fn v, acc ->
      if v, do: acc + 1, else: acc
    end)
  end

  defp part2(input) do
    input
    |> Enum.map(&is_safe2?/1)
    |> Enum.reduce(0, fn v, acc ->
      if v, do: acc + 1, else: acc
    end)
  end

  defp try_removals(_numbers, x, x), do: false

  defp try_removals(numbers, x, count) do
    new_numbers =
      cond do
        x == 0 -> Enum.drop(numbers, 1)
        x == count - 1 -> Enum.slice(numbers, 0..(count - 2))
        true -> Enum.slice(numbers, 0..(x - 1)) ++ Enum.slice(numbers, (x + 1)..-1//1)
      end

    if is_safe?(new_numbers) do
      true
    else
      try_removals(numbers, x + 1, count)
    end
  end

  defp is_safe2?(numbers) do
    count = Enum.count(numbers)

    if not is_safe?(numbers) do
      try_removals(numbers, 0, count)
    else
      true
    end
  end

  def run() do
    test_input =
      """
      7 6 4 2 1
      1 2 7 8 9
      9 7 6 2 1
      1 3 2 4 5
      8 6 4 4 1
      1 3 6 7 9
      """
      |> parse()

    input =
      Advent.daily_input("2024", "02")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
