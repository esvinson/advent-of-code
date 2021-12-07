defmodule Aoc202104 do
  def parse(input) do
    [picks | boards] =
      input
      |> String.split("\n\n", trim: true)

    parsed_picks = String.split(picks, ",", trim: true) |> Enum.map(&String.to_integer/1)

    parsed_boards =
      boards
      |> Enum.map(fn board ->
        board
        |> String.replace("\n", " ")
        |> String.split()
        |> Enum.map(&String.to_integer/1)
      end)

    {parsed_picks, parsed_boards}
  end

  defp create_boards(raw_boards) do
    raw_boards
    |> Enum.map(fn board ->
      layout =
        board
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {element, index}, acc ->
          x = rem(index, 5)
          y = div(index, 5)
          Map.put(acc, element, {x, y})
        end)

      %{layout: layout, visited: Tuple.duplicate(Tuple.duplicate(false, 5), 5)}
    end)
  end

  def win?(%{visited: visited}) do
    Enum.any?(0..4, fn y -> elem(visited, y) == Tuple.duplicate(true, 5) end) or
      Enum.any?(0..4, fn x -> Enum.all?(0..4, fn y -> visited |> elem(y) |> elem(x) end) end)
  end

  defp run_picks(boards, picks) do
    Enum.reduce_while(picks, boards, fn pick, boards ->
      boards =
        boards
        |> Enum.map(fn
          %{layout: %{^pick => {x, y}}} = board ->
            put_in(board, [Access.key(:visited), Access.elem(y), Access.elem(x)], true)

          %{} = board ->
            board
        end)

      case Enum.find(boards, &win?(&1)) do
        %{} = board ->
          {:halt, {board, pick}}

        _ ->
          {:cont, boards}
      end
    end)
  end

  defp count_unmarked(%{visited: visited, layout: layout}) do
    map = layout |> Advent.Algorithms.inverse()

    for y <- 0..4 do
      for x <- 0..4 do
        {x, y}
      end
    end
    |> List.flatten()
    |> Enum.filter(fn {x, y} ->
      not (visited |> elem(y) |> elem(x))
    end)
    |> Enum.map(fn pos -> Map.get(map, pos) end)
    |> Enum.sum()
  end

  def part1({picks, raw_boards}) do
    {board, pick} =
      raw_boards
      |> create_boards()
      |> run_picks(picks)

    count_unmarked(board) * pick
  end

  defp run_picks_part2(boards, picks) do
    Enum.reduce_while(picks, boards, fn pick, boards ->
      boards =
        boards
        |> Enum.map(fn
          %{layout: %{^pick => {x, y}}} = board ->
            put_in(board, [Access.key(:visited), Access.elem(y), Access.elem(x)], true)

          %{} = board ->
            board
        end)

      boards
      |> Enum.filter(&(not win?(&1)))
      |> case do
        [] ->
          [board] = boards
          {:halt, {board, pick}}

        boards ->
          {:cont, boards}
      end
    end)
  end

  def part2({picks, raw_boards}) do
    {board, pick} =
      raw_boards
      |> create_boards()
      |> run_picks_part2(picks)

    count_unmarked(board) * pick
  end

  def run do
    test_input = Advent.daily_input("2021", "04.test") |> parse()

    input =
      Advent.daily_input("2021", "04")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
