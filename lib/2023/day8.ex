defmodule Aoc202308 do
  defp parse(input) do
    [directions, mapping] = String.split(input, "\n\n", trim: true)
    # directions = String.split(directions, "", trim: true)

    mapping =
      mapping
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn x, acc ->
        [key, left, right] = String.split(x, ~r/[^a-z]/i, trim: true)
        Map.put(acc, key, {left, right})
      end)

    {directions, mapping}
  end

  defp get_from_map(map, location, "L"), do: Map.get(map, location) |> elem(0)
  defp get_from_map(map, location, "R"), do: Map.get(map, location) |> elem(1)

  defp iterate(directions, total_directions, count, map, location) do
    direction = String.at(directions, rem(count, total_directions))
    next_location = get_from_map(map, location, direction)

    if next_location == "ZZZ" do
      1
    else
      1 + iterate(directions, total_directions, count + 1, map, next_location)
    end
  end

  defp part1({directions, map}) do
    total_directions = String.length(directions)
    iterate(directions, total_directions, 0, map, "AAA")
  end

  # defp part2(input) do
  #   input
  # end

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

    input =
      Advent.daily_input("2023", "08")
      |> parse()

    IO.puts("Test Answer Part 1 (1): #{inspect(part1(test_input1))}")
    IO.puts("Test Answer Part 1 (2): #{inspect(part1(test_input2))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
