defmodule Aoc202205 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      %{"count" => count, "source" => source, "destination" => destination} =
        Regex.named_captures(
          ~r/move (?<count>\d+) from (?<source>\d+) to (?<destination>\d+)/,
          row
        )

      [count, source, destination] |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  defp move(state, source, destination) do
    [val | rest] = Map.get(state, source)

    state
    |> Map.update(source, rest, fn _ -> rest end)
    |> Map.update(destination, val, fn current -> [val] ++ current end)
  end

  defp run_movement(state, []), do: state
  defp run_movement(state, [{0, _, _} | rest]), do: run_movement(state, rest)

  defp run_movement(state, movement) do
    [{count, source, destination} | rest] = movement
    new_state = move(state, source, destination)
    run_movement(new_state, [{count - 1, source, destination}] ++ rest)
  end

  def part1(start, movement) do
    run_movement(start, movement)
    # |> IO.inspect()
    |> Enum.map(fn {_, [first | _rest]} -> first end)
  end

  defp move2(state, count, source, destination) do
    tmp = Map.get(state, source)
    {val, rest} = String.split_at(tmp, count)

    state
    |> Map.update(source, rest, fn _ -> rest end)
    |> Map.update(destination, val, fn current -> val <> current end)
  end

  defp run_movement2(state, []), do: state

  defp run_movement2(state, [{count, source, destination} | rest]) do
    new_state = move2(state, count, source, destination)
    run_movement2(new_state, rest)
  end

  def part2(start, movement) do
    start
    |> Enum.map(fn {key, val} -> {key, to_string(val)} end)
    |> Map.new()
    |> run_movement2(movement)
    # |> IO.inspect()
    |> Enum.map(fn {_, chars} -> String.first(chars) end)
    |> Enum.join()
  end

  def run do
    #     [D]
    # [N] [C]
    # [Z] [M] [P]
    #  1   2   3
    test_start = %{
      1 => ~c"NZ",
      2 => ~c"DCM",
      3 => ~c"P"
    }

    test_input =
      """
      move 1 from 2 to 1
      move 3 from 1 to 3
      move 2 from 2 to 1
      move 1 from 1 to 2
      """
      |> parse

    start = %{
      1 => ~c"DHRZSPWQ",
      2 => ~c"FHQWRBV",
      3 => ~c"HSVC",
      4 => ~c"GFH",
      5 => ~c"ZBJGP",
      6 => ~c"LFWHJTQ",
      7 => ~c"NJVLDWTZ",
      8 => ~c"FHGJCZTD",
      9 => ~c"HBMVPW"
    }

    input =
      Advent.daily_input("2022", "05")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_start, test_input))}")
    IO.puts("Part 1: #{inspect(part1(start, input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_start, test_input))}")
    IO.puts("Part 2: #{inspect(part2(start, input))}")
  end
end
