defmodule Aoc202501 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      direction = String.at(row, 0)
      number = String.replace(row, ~r"^[RL]", "")
      {direction, String.to_integer(number)}
    end)
  end

  defp rotate({zeros, current}, {"R", val}) do
    newval = Integer.mod(current + val, 100)
    newzeros = if newval == 0, do: zeros + 1, else: zeros
    {newzeros, newval}
  end

  defp rotate({zeros, current}, {"L", val}) do
    newval = Integer.mod(current - val, 100)
    newzeros = if newval == 0, do: zeros + 1, else: zeros
    {newzeros, newval}
  end

  defp part1(input) do
    {zeros, _} =
      Enum.reduce(input, {0, 50}, fn row, acc ->
        rotate(acc, row)
      end)

    zeros
  end

  defp rotate2({zeros, current}, {"R", val}) do
    newval_pre_mod = current + val
    seen_zeros = Integer.floor_div(newval_pre_mod, 100)
    newval = Integer.mod(newval_pre_mod, 100)
    newzeros = zeros + seen_zeros
    {newzeros, newval}
  end

  defp rotate2({zeros, current}, {"L", val}) do
    newval_pre_mod = current - val
    newval = Integer.mod(newval_pre_mod, 100)

    seen_zeros = abs(Integer.floor_div(newval_pre_mod, 100))
    seen_zeros = if current == 0, do: seen_zeros - 1, else: seen_zeros
    seen_zeros = if newval == 0, do: seen_zeros + 1, else: seen_zeros
    newval = Integer.mod(newval_pre_mod, 100)
    newzeros = zeros + seen_zeros
    {newzeros, newval}
  end

  defp part2(input) do
    {zeros, _} =
      Enum.reduce(input, {0, 50}, fn row, acc ->
        # IO.inspect({acc, row})
        rotate2(acc, row)
      end)

    zeros
  end

  def run() do
    test_input =
      """
      L68
      L30
      R48
      L5
      R60
      L55
      L1
      L99
      R14
      L82
      """
      |> parse()

    input =
      Advent.daily_input("2025", "01")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2 (6): #{inspect(part2(test_input))}")
    IO.puts("Test Answer Part 2 (10): #{inspect(part2([{"R", 1000}]))}")
    IO.puts("Test Answer Part 2 (11): #{inspect(part2([{"L", 50}, {"R", 1000}]))}")
    IO.puts("Test Answer Part 2 (11): #{inspect(part2([{"R", 50}, {"R", 1000}]))}")
    IO.puts("Test Answer Part 2 (11): #{inspect(part2([{"R", 51}, {"R", 1000}]))}")
    IO.puts("Test Answer Part 2 (10): #{inspect(part2([{"L", 1000}]))}")
    IO.puts("Test Answer Part 2 (11): #{inspect(part2([{"L", 50}, {"L", 1000}]))}")
    IO.puts("Test Answer Part 2 (11): #{inspect(part2([{"R", 50}, {"L", 1000}]))}")
    IO.puts("Test Answer Part 2 (11): #{inspect(part2([{"L", 51}, {"L", 1000}]))}")
    # not 6134, not 5418, not 7273, not 6697
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
