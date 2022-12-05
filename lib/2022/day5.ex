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
    |> IO.inspect()
    |> Enum.map(fn {_, [first | _rest]} -> first end)
  end

  # def part2(start, movement) do
  # end

  def run do
    #     [D]
    # [N] [C]
    # [Z] [M] [P]
    #  1   2   3
    test_start = %{
      1 => 'NZ',
      2 => 'DCM',
      3 => 'P'
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
      1 => 'DHRZSPWQ',
      2 => 'FHQWRBV',
      3 => 'HSVC',
      4 => 'GFH',
      5 => 'ZBJGP',
      6 => 'LFWHJTQ',
      7 => 'NJVLDWTZ',
      8 => 'FHGJCZTD',
      9 => 'HBMVPW'
    }

    input =
      Advent.daily_input("2022", "05")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_start, test_input))}")
    IO.puts("Part 1: #{inspect(part1(start, input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
