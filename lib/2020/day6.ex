defmodule Aoc202006 do
  defp test_input,
    do: """
    abc

    a
    b
    c

    ab
    ac

    a
    a
    a
    a

    b
    """

  defp output_to_list(input) do
    input
    |> to_string()
    |> String.split("\n\n", trim: true)
  end

  defp part1(list) do
    list
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/[\n ]/, "")
      |> String.graphemes()
      |> Enum.sort()
      |> Enum.dedup()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def part2(list) do
    list
    |> Enum.map(fn line ->
      result_sets =
        line
        |> String.split("\n", trim: true)
        |> Enum.map(fn row ->
          row
          |> String.graphemes()
          |> Enum.reduce(MapSet.new(), fn question, mapset ->
            MapSet.put(mapset, question)
          end)
        end)

      case length(result_sets) do
        1 ->
          result_sets
          |> List.first()

        _n ->
          Enum.reduce(result_sets, List.first(result_sets), fn x, mapset ->
            MapSet.intersection(x, mapset)
          end)
      end
      |> MapSet.to_list()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def run do
    test_list =
      test_input()
      |> output_to_list()

    list =
      Advent.daily_input("2020", "06")
      |> output_to_list()

    test_result1 = part1(test_list)
    IO.puts("Solution to Test Part 1 (Should be 11): #{test_result1}")

    result1 = part1(list)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2 = part2(test_list)
    IO.puts("Solution to Test Part 2 (Should be 6): #{inspect(test_result2)}")

    result2 = part2(list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
