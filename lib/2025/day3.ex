defmodule Aoc202503 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) |> Enum.map(&String.to_integer/1) end)
  end

  defp find_biggest([], max1, max2), do: [max1, max2]

  defp find_biggest([a | rest], max1, max2) do
    if a >= max1 do
      find_biggest(rest, a, max1)
    else
      if Enum.find(rest, false, fn x -> x == max1 end) do
        if a > max2 do
          find_biggest(rest, max1, a)
        else
          find_biggest(rest, max1, max2)
        end
      else
        find_biggest(rest, max1, max2)
      end
    end
  end

  defp part1(banks) do
    Enum.map(banks, fn bank ->
      # IO.inspect(bank, label: "bank ===>", printable_limit: :infinity, limit: :infinity)
      rbank = Enum.reverse(bank)
      [first | rest] = rbank
      [a, b] = find_biggest(rbank, 0, 0)
      [a, b] = if b == 0, do: [List.first(find_biggest(rest, 0, 0)), first], else: [a, b]

      Integer.undigits([a, b])
      # |> IO.inspect(label: "RESULT ===>")
    end)
    |> Enum.sum()
  end

  # defp part2(input) do
  #   input
  # end

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
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
