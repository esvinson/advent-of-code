defmodule Aoc202403 do
  defp multiply(rows) do
    rows
    |> Enum.map(fn row ->
      %{"left" => left, "right" => right} =
        Regex.named_captures(~r/mul\((?<left>\d+),(?<right>\d+)\)/, row)

      String.to_integer(left) * String.to_integer(right)
    end)
  end

  defp part1(input) do
    Regex.scan(~r/mul\(\d+,\d+\)/, input)
    |> List.flatten()
    |> multiply()
    |> Enum.sum()
  end

  defp remove_disabled([], _enabled), do: []

  defp remove_disabled([item | list], enabled) do
    case item do
      "do()" ->
        remove_disabled(list, true)

      "don't()" ->
        remove_disabled(list, false)

      _ ->
        if enabled,
          do: [item] ++ remove_disabled(list, true),
          else: remove_disabled(list, false)
    end
  end

  defp part2(input) do
    Regex.scan(~r/(mul\(\d+,\d+\)|do\(\)|don't\(\))/, input, capture: :first)
    |> List.flatten()
    |> remove_disabled(true)
    |> multiply()
    |> Enum.sum()
  end

  def run() do
    test_input =
      "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

    test_input2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

    input = Advent.daily_input("2024", "03")

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input2))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
