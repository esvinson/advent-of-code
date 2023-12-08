defmodule Aoc202308 do
  alias Advent.Algorithms

  defp parse(input) do
    [directions, mapping] = String.split(input, "\n\n", trim: true)
    # directions = String.split(directions, "", trim: true)

    mapping =
      mapping
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn x, acc ->
        [key, left, right] = String.split(x, ~r/[^a-z\d]/i, trim: true)
        Map.put(acc, key, {left, right})
      end)

    {directions, mapping}
  end

  defp get_from_map(map, location, "L"), do: Map.get(map, location) |> elem(0)
  defp get_from_map(map, location, "R"), do: Map.get(map, location) |> elem(1)

  defp iterate(directions, total_directions, count, map, location, match \\ ~r/ZZZ/) do
    direction = String.at(directions, rem(count, total_directions))
    next_location = get_from_map(map, location, direction)

    if String.match?(next_location, match) do
      1
    else
      1 + iterate(directions, total_directions, count + 1, map, next_location, match)
    end
  end

  defp part1({directions, map}) do
    total_directions = String.length(directions)
    iterate(directions, total_directions, 0, map, "AAA")
  end

  defp part2({directions, map}) do
    total_directions = String.length(directions)

    starting_locations =
      map
      |> Map.keys()
      |> Enum.reduce([], fn key, acc ->
        if String.at(key, 2) == "A",
          do: [key] ++ acc,
          else: acc
      end)

    Enum.reduce(starting_locations, [], fn location, acc ->
      [iterate(directions, total_directions, 0, map, location, ~r/^..Z$/)] ++ acc
    end)
    |> Algorithms.lcm()
  end

  def run() do
    test_input1 =
      """
      RL

      AAA = (BBB, CCC)
      BBB = (DDD, EEE)
      CCC = (ZZZ, GGG)
      DDD = (DDD, DDD)
      EEE = (EEE, EEE)
      GGG = (GGG, GGG)
      ZZZ = (ZZZ, ZZZ)
      """
      |> parse()

    test_input2 =
      """
      LLR

      AAA = (BBB, BBB)
      BBB = (AAA, ZZZ)
      ZZZ = (ZZZ, ZZZ)
      """
      |> parse()

    test_input3 =
      """
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
      """
      |> parse()

    input =
      Advent.daily_input("2023", "08")
      |> parse()

    IO.puts("Test Answer Part 1 (1): #{inspect(part1(test_input1))}")
    IO.puts("Test Answer Part 1 (2): #{inspect(part1(test_input2))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input3))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
