defmodule Aoc202504 do
  defp parse(input) do
    [first | _rest] =
      start =
      input
      |> String.split("\n", trim: true)

    max_y = Enum.count(start)
    max_x = String.length(first)

    map =
      start
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc1 ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc1, fn {val, x}, acc2 ->
          if val == "@" do
            Map.put(acc2, {x, y}, val)
          else
            acc2
          end
        end)
      end)

    %{map: map, height: max_y, width: max_x}
  end

  defp part1(%{map: map}) do
    map
    |> Map.keys()
    |> Enum.map(fn {x, y} ->
      rolls =
        for i <- (x - 1)..(x + 1),
            j <- (y - 1)..(y + 1),
            {i, j} != {x, y} and not is_nil(Map.get(map, {i, j})),
            do: {i, j}

      Enum.count(rolls)
    end)
    |> Enum.filter(fn x -> x < 4 end)
    |> Enum.count()
  end

  defp remove_rolls(map, total_removed) do
    rolls_to_remove =
      map
      |> Map.keys()
      |> Enum.map(fn {x, y} ->
        rolls =
          for i <- (x - 1)..(x + 1),
              j <- (y - 1)..(y + 1),
              {i, j} != {x, y} and not is_nil(Map.get(map, {i, j})),
              do: {i, j}

        {{x, y}, Enum.count(rolls)}
      end)
      |> Enum.filter(fn {_, x} -> x < 4 end)
      |> Enum.map(fn {{x, y}, _} ->
        {x, y}
      end)

    count = Enum.count(rolls_to_remove)

    if count == 0 do
      total_removed
    else
      map
      |> Map.drop(rolls_to_remove)
      |> remove_rolls(total_removed + count)
    end
  end

  defp part2(%{map: map}) do
    remove_rolls(map, 0)
  end

  def run() do
    test_input =
      """
      ..@@.@@@@.
      @@@.@.@.@@
      @@@@@.@.@@
      @.@@@@..@.
      @@.@@@@.@@
      .@@@@@@@.@
      .@.@.@.@@@
      @.@@@.@@@@
      .@@@@@@@@.
      @.@.@@@.@.
      """
      |> parse()

    input =
      Advent.daily_input("2025", "04")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
