defmodule Aoc202025 do
  def test_input, do: [5_764_801, 17_807_724]

  def input, do: [8_421_034, 15_993_936]

  @shared_secret 20_201_227

  def recurse(key1, key2, x) do
    cond do
      :binary.decode_unsigned(:crypto.mod_pow(7, x, @shared_secret)) == key1 ->
        {:key1, x}

      :binary.decode_unsigned(:crypto.mod_pow(7, x, @shared_secret)) == key2 ->
        {:key2, x}

      true ->
        recurse(key1, key2, x + 1)
    end
  end

  def part1([key1, key2]) do
    recurse(key1, key2, 1)
    |> case do
      {:key1, x} ->
        :binary.decode_unsigned(:crypto.mod_pow(key2, x, @shared_secret))

      {:key2, x} ->
        :binary.decode_unsigned(:crypto.mod_pow(key1, x, @shared_secret))
    end
  end

  def run do
    IO.puts("Solution to Test Part 1 (Should be 14897079): #{inspect(part1(test_input()))}")
    part1(test_input())

    result1 = part1(input())
    IO.puts("Solution to Part 1: #{result1}")
  end
end
