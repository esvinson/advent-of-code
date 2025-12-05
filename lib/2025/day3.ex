defmodule Aoc202503 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) |> Enum.map(&String.to_integer/1) end)
  end

  # Reworked with inspirtion from jollyjerr's implementation: https://github.com/jollyjerr/advent-of-code/blob/main/2025/3/main.c
  defp search(_bank, _len, _start, digits, output)
       when length(output) == digits,
       do: Integer.undigits(Enum.reverse(output))

  defp search(bank, len, start, digits, output) do
    bank_length = Enum.count(bank)
    output_length = Enum.count(output)

    {max_index, max_val} =
      bank
      |> Enum.slice(start, len + 1 - start)
      |> Enum.max_by(fn {index, element} ->
        {element, index * -1}
      end)

    search(
      bank,
      bank_length - (digits - (output_length + 1)),
      max_index + 1,
      digits,
      [max_val] ++ output
    )
  end

  defp sum_banks(banks, digits) do
    Enum.map(banks, fn bank ->
      len = Enum.count(bank)

      bank
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> search(len - digits, 0, digits, [])
    end)
    |> Enum.sum()
  end

  defp part1(banks) do
    sum_banks(banks, 2)
  end

  defp part2(banks) do
    sum_banks(banks, 12)
  end

  def run() do
    test_input =
      """
      987654321111111
      811111111111119
      234234234234278
      818181911112111
      """
      |> parse()

    input =
      Advent.daily_input("2025", "03")
      |> parse()

    IO.puts("Test Answer Part 1 (357): #{inspect(part1(test_input), charlists: :as_lists)}")
    # Not 17073, Not 17208
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")

    IO.puts(
      "Test Answer Part 2 (3121910778619): #{inspect(part2(test_input), charlists: :as_lists)}"
    )

    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
