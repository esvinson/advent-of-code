defmodule Aoc202213 do
  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn set ->
      set
      |> String.split("\n", trim: true)
      |> Enum.map(fn x ->
        {output, _} = Code.eval_string(x)
        output
      end)
    end)
  end

  @spec valid?(list(), list()) :: {atom(), boolean()}
  defp valid?([], []), do: {:cont, true}
  defp valid?([], _), do: {:final, true}
  defp valid?(_, []), do: {:final, false}

  defp valid?([[] | arest], [[] | brest]) do
    valid?(arest, brest)
  end

  defp valid?([[] | _arest], _), do: {:final, true}
  defp valid?(_, [[] | _brest]), do: {:final, false}
  defp valid?([a | arest], [a | brest]) when is_integer(a), do: valid?(arest, brest)

  # and valid?(arest, brest)
  defp valid?([a | arest], [b | brest]) when is_list(a) and not is_list(b) do
    valid?(a, [b])
    |> case do
      {:cont, _} -> valid?(arest, brest)
      val -> val
    end
  end

  # and valid?(arest, brest)
  defp valid?([a | arest], [b | brest]) when not is_list(a) and is_list(b) do
    valid?([a], b)
    |> case do
      {:cont, _} -> valid?(arest, brest)
      val -> val
    end
  end

  # and valid?(arest, brest)
  defp valid?([a | arest], [b | brest]) when is_list(a) and is_list(b) do
    valid?(a, b)
    |> case do
      {:cont, _} -> valid?(arest, brest)
      val -> val
    end
  end

  # a == b

  defp valid?([a | _arest], [b | _brest]) when not is_list(a) and not is_list(b),
    do: {:final, a < b}

  def part1(sets) do
    sets
    |> Enum.with_index(1)
    |> Enum.map(fn {[a, b], index} -> {index, valid?(a, b)} end)
    |> Enum.filter(fn {_index, {:final, valid}} -> valid end)
    |> Enum.reduce(0, fn {index, _}, acc -> acc + index end)
  end

  def run do
    test_input =
      """
      [1,1,3,1,1]
      [1,1,5,1,1]

      [[1],[2,3,4]]
      [[1],4]

      [9]
      [[8,7,6]]

      [[4,4],4,4]
      [[4,4],4,4,4]

      [7,7,7,7]
      [7,7,7]

      []
      [3]

      [[[]]]
      [[]]

      [1,[2,[3,[4,[5,6,7]]]],8,9]
      [1,[2,[3,[4,[5,6,0]]]],8,9]
      """
      |> parse()

    input = Advent.daily_input("2022", "13") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
