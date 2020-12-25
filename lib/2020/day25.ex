defmodule Aoc202025 do
  alias Advent.Algorithms
  def test_input, do: [5_764_801, 17_807_724]

  def input, do: [8_421_034, 15_993_936]

  @shared_secret 20_201_227

  def find_loop_size(key1, value, x) do
    rem(7 * value, @shared_secret)
    |> case do
      val when val == key1 ->
        {:key1, x}

      val ->
        find_loop_size(key1, val, x + 1)
    end
  end

  def part1([key1, key2]) do
    find_loop_size(key1, 1, 1)
    |> case do
      {:key1, x} ->
        Algorithms.powmod(key2, x, @shared_secret)

        # {:key2, x} ->
        #   powmod(key1, x, @shared_secret)
    end
  end

  def run do
    IO.puts("Solution to Test Part 1 (Should be 14897079): #{inspect(part1(test_input()))}")
    part1(test_input())

    result1 = part1(input())
    IO.puts("Solution to Part 1: #{result1}")
  end
end
