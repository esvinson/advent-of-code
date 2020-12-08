defmodule Aoc202003 do
  defp test_input,
    do: """
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    """

  defp output_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist(&1))
  end

  def part1(list) do
    len = list |> Enum.at(0) |> Enum.count()
    hash = '#' |> Enum.at(0)

    list
    |> Enum.drop(1)
    |> Enum.reduce({0, 0}, fn row, {x, counter} ->
      new_x = rem(x + 3, len)
      new_counter = if Enum.at(row, new_x) == hash, do: counter + 1, else: counter
      {new_x, new_counter}
    end)
    |> elem(1)
  end

  defp drop_rows(list, 1) do
    list
    |> Enum.drop(1)
  end

  defp drop_rows(list, y_offset) do
    list
    |> Enum.drop(1)
    |> Enum.drop_every(y_offset)
  end

  def part2(list) do
    len = list |> Enum.at(0) |> Enum.count()
    hash = '#' |> Enum.at(0)

    [
      {1, 1},
      {3, 1},
      {5, 1},
      {7, 1},
      {1, 2}
    ]
    |> Enum.map(fn {x_offset, y_offset} ->
      list
      |> drop_rows(y_offset)
      |> Enum.reduce({0, 0}, fn row, {x, counter} ->
        new_x = rem(x + x_offset, len)
        new_counter = if Enum.at(row, new_x) == hash, do: counter + 1, else: counter
        {new_x, new_counter}
      end)
      |> elem(1)
    end)
    |> Enum.reduce(1, fn trees, acc -> acc * trees end)
  end

  def run do
    test_list = test_input() |> output_to_list()
    list = Advent.daily_input("2020", "03") |> output_to_list()
    testresult1 = part1(test_list)
    IO.puts("Solution to Part 1 Test (should be 7): #{testresult1}")

    result1 = part1(list)
    IO.puts("Solution to Part 1: #{result1}")

    testresult2 = part2(test_list)
    IO.puts("Solution to Part 2 Test (should be 336): #{testresult2}")

    result2 = part2(list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
