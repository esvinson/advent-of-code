defmodule Aoc202112 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-", trim: true))
  end

  def build_paths(list) do
    list
    |> Enum.reduce(%{}, fn [left, right], acc ->
      cond do
        left == "start" ->
          Map.update(acc, left, [right], fn x -> [right] ++ x end)

        right == "start" ->
          Map.update(acc, right, [left], fn x -> [left] ++ x end)

        left == "end" ->
          Map.update(acc, right, [left], fn x -> [left] ++ x end)

        right == "end" ->
          Map.update(acc, left, [right], fn x -> [right] ++ x end)

        true ->
          acc
          |> Map.update(left, [right], fn x -> [right] ++ x end)
          |> Map.update(right, [left], fn x -> [left] ++ x end)
      end
    end)
  end

  def recurse(_path_map, [], _seen, _one_small, count), do: count

  def recurse(path_map, ["end" | queue], seen, one_small, count),
    do: recurse(path_map, queue, seen, one_small, count + 1)

  def recurse(path_map, [current | queue], seen, one_small, count) do
    neighbors = path_map[current]

    count =
      cond do
        current in seen and one_small ->
          count

        current in seen ->
          recurse(path_map, neighbors, seen, true, count)

        String.downcase(current) == current ->
          seen = MapSet.put(seen, current)
          recurse(path_map, neighbors, seen, one_small, count)

        true ->
          recurse(path_map, neighbors, seen, one_small, count)
      end

    recurse(path_map, queue, seen, one_small, count)
  end

  def part1(list) do
    map =
      list
      |> build_paths()

    recurse(map, map["start"], MapSet.new(), true, 0)
  end

  def part2(list) do
    map =
      list
      |> build_paths()

    recurse(map, map["start"], MapSet.new(), false, 0)
  end

  def run do
    test_input =
      """
      start-A
      start-b
      A-c
      A-b
      b-d
      A-end
      b-end
      """
      |> parse()

    test_input2 =
      """
      dc-end
      HN-start
      start-kj
      dc-start
      dc-HN
      LN-dc
      HN-end
      kj-sa
      kj-HN
      kj-dc
      """
      |> parse()

    test_input3 =
      """
      fs-end
      he-DX
      fs-he
      start-DX
      pj-DX
      end-zg
      zg-sl
      zg-pj
      pj-he
      RW-he
      fs-DX
      pj-RW
      zg-RW
      start-pj
      he-WI
      zg-he
      pj-fs
      start-RW
      """
      |> parse()

    input =
      Advent.daily_input("2021", "12")
      |> parse()

    IO.puts("Test Answer Part 1 #1: #{inspect(part1(test_input))}")
    IO.puts("Test Answer Part 1 #2: #{inspect(part1(test_input2))}")
    IO.puts("Test Answer Part 1 #3: #{inspect(part1(test_input3))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2 #1: #{inspect(part2(test_input))}")
    IO.puts("Test Answer Part 2 #2: #{inspect(part2(test_input2))}")
    IO.puts("Test Answer Part 2 #3: #{inspect(part2(test_input3))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
