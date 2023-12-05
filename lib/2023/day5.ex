defmodule Aoc202305 do
  def order, do: ["soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  defp parse(input) do
    sets =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    [[seeds] | maps] = sets

    seeds =
      seeds
      |> String.replace("seeds: ", "")
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer(&1))

    mapping_out =
      maps
      |> Enum.reduce(%{}, fn [name | mappings], acc ->
        name = name |> String.replace(~r/[^-]+-to-([^ ]+) map:/, "\\1")

        mappings =
          mappings
          |> Enum.map(fn x ->
            x
            |> String.split(" ")
            |> Enum.map(&String.to_integer(&1))
            |> List.to_tuple()
          end)

        Map.put(acc, name, mappings)
      end)

    {seeds, mapping_out}
  end

  defp remap({destination, source_start, source_range}, find_val)
       when find_val >= source_start and find_val - source_start < source_range,
       do: destination + (find_val - source_start)

  defp remap(_, _find_val), do: false

  defp part1({seeds, mappings}) do
    Enum.map(seeds, fn seed ->
      Enum.reduce(order(), seed, fn map_id, starting_value ->
        Enum.reduce_while(mappings[map_id], starting_value, fn map, value_to_map ->
          remap(map, value_to_map)
          |> case do
            false ->
              {:cont, value_to_map}

            val ->
              {:halt, val}
          end
        end)
      end)
    end)
    |> Enum.min()
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      seeds: 79 14 55 13

      seed-to-soil map:
      50 98 2
      52 50 48

      soil-to-fertilizer map:
      0 15 37
      37 52 2
      39 0 15

      fertilizer-to-water map:
      49 53 8
      0 11 42
      42 0 7
      57 7 4

      water-to-light map:
      88 18 7
      18 25 70

      light-to-temperature map:
      45 77 23
      81 45 19
      68 64 13

      temperature-to-humidity map:
      0 69 1
      1 0 69

      humidity-to-location map:
      60 56 37
      56 93 4
      """
      |> parse()

    input =
      Advent.daily_input("2023", "05")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
