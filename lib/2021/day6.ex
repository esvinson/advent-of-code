defmodule Aoc202106 do
  def parse(input) do
    input
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp age(fish) do
    Enum.reduce(fish, {0, []}, fn fish, {zeros, acc} ->
      if fish == 0, do: {zeros + 1, [6] ++ acc}, else: {zeros, [fish - 1] ++ acc}
    end)
  end

  defp run(fish, 0), do: fish

  defp run(fish, steps) do
    {zeros, old_fish} = age(fish)

    new_fish = for _ <- 0..(zeros - 1), do: 8

    if zeros > 0 do
      run(old_fish ++ new_fish, steps - 1)
    else
      run(old_fish, steps - 1)
    end
  end

  def part1(initial) do
    initial
    |> run(80)
    |> Enum.count()
  end

  defp bucket([], result), do: result

  defp bucket([0 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero + 1, one, two, three, four, five, six, seven, eight})

  defp bucket([1 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one + 1, two, three, four, five, six, seven, eight})

  defp bucket([2 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two + 1, three, four, five, six, seven, eight})

  defp bucket([3 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two, three + 1, four, five, six, seven, eight})

  defp bucket([4 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two, three, four + 1, five, six, seven, eight})

  defp bucket([5 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two, three, four, five + 1, six, seven, eight})

  defp bucket([6 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two, three, four, five, six + 1, seven, eight})

  defp bucket([7 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two, three, four, five, six, seven + 1, eight})

  defp bucket([8 | fish], {zero, one, two, three, four, five, six, seven, eight}),
    do: bucket(fish, {zero, one, two, three, four, five, six, seven, eight + 1})

  defp run_part2(state, 0), do: state

  defp run_part2({zero, one, two, three, four, five, six, seven, eight}, step),
    do: run_part2({one, two, three, four, five, six, seven + zero, eight, zero}, step - 1)

  def part2(initial_fish) do
    initial_state = for(_ <- 0..8, do: 0) |> List.to_tuple()

    initial_fish
    |> bucket(initial_state)
    |> run_part2(256)
    |> Tuple.to_list()
    |> Enum.sum()
  end

  def run do
    test_input = "3,4,3,1,2" |> parse()

    input =
      Advent.daily_input("2021", "06")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
