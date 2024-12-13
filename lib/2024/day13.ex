defmodule Aoc202413 do
  defp parse_machine(definition) do
    [a, b, prize] = String.split(definition, "\n", trim: true)

    a =
      a
      |> String.replace("Button A: X", "")
      |> String.replace(" Y", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    b =
      b
      |> String.replace("Button B: X", "")
      |> String.replace(" Y", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    prize =
      prize
      |> String.replace("Prize: X=", "")
      |> String.replace(" Y=", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {a, b, prize}
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_machine/1)
  end

  defp check(0, _machine), do: :invalid

  defp check(iteration, {[ax, ay], [bx, by], [prizex, prizey]} = machine) do
    leftx = prizex - bx * iteration

    if rem(leftx, ax) == 0 do
      ax_count = div(leftx, ax)
      lefty = prizey - by * iteration
      ay_count = div(lefty, ay)

      if rem(lefty, ay) == 0 and ax_count == ay_count do
        {ax_count, iteration}
      else
        check(iteration - 1, machine)
      end
    else
      check(iteration - 1, machine)
    end
  end

  defp part1(list) do
    list
    |> Enum.map(fn {[_ax, _ay], [bx, by], [prizex, prizey]} = machine ->
      max_iterations_b = [floor(prizex / bx), floor(prizey / by), 100] |> Enum.min()

      max_iterations_b
      |> check(machine)
      |> case do
        {a, b} -> a * 3 + b
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      Button A: X+94, Y+34
      Button B: X+22, Y+67
      Prize: X=8400, Y=5400

      Button A: X+26, Y+66
      Button B: X+67, Y+21
      Prize: X=12748, Y=12176

      Button A: X+17, Y+86
      Button B: X+84, Y+37
      Prize: X=7870, Y=6450

      Button A: X+69, Y+23
      Button B: X+27, Y+71
      Prize: X=18641, Y=10279
      """
      |> parse()

    input =
      Advent.daily_input("2024", "13")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
