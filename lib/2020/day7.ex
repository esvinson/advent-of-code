defmodule Aoc202007 do
  defp test_input,
    do: """
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
    """

  defp test_input2,
    do: """
    shiny gold bags contain 2 dark red bags.
    dark red bags contain 2 dark orange bags.
    dark orange bags contain 2 dark yellow bags.
    dark yellow bags contain 2 dark green bags.
    dark green bags contain 2 dark blue bags.
    dark blue bags contain 2 dark violet bags.
    dark violet bags contain no other bags.
    """

  defp output_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
  end

  defp remap(list) do
    contains =
      list
      |> Enum.map(fn row ->
        row
        |> String.replace(~r/\.$/, "")
        |> String.replace(" bags contain ", ",")
        |> String.replace("no other bags", "")
        |> String.replace(~r/\s?,\s?/, ",")
        |> String.replace(~r/ bags?/, "")
        |> String.split(",", trim: true)
      end)
      |> Enum.reduce(%{}, fn [key | vals], acc ->
        transformed_vals =
          vals
          |> Enum.reduce(%{}, fn bags, sub_acc ->
            [bag_count, bag] =
              bags
              |> String.split(" ", parts: 2, trim: true)

            Map.put(sub_acc, bag, String.to_integer(bag_count))
          end)

        Map.put(acc, key, transformed_vals)
      end)

    inside =
      Enum.reduce(contains, %{}, fn {parentKey, vals}, acc ->
        Enum.reduce(vals, acc, fn {key, _val}, subacc ->
          current = Map.get(subacc, key, [])
          Map.put(subacc, key, [parentKey] ++ current)
        end)
      end)

    {contains, inside}
  end

  defp dive(key, list) do
    internal_bags = Map.get(list, key, [])

    if length(internal_bags) == 0 do
      [key]
    else
      Enum.reduce(internal_bags, [key], fn parentKey, acc ->
        acc ++ dive(parentKey, list)
      end)
    end
  end

  defp dive2(key, list) do
    Map.get(list, key, [])
    |> Enum.reduce(0, fn {parentKey, val}, acc ->
      acc + val * dive2(parentKey, list)
    end)
    |> Kernel.+(1)
  end

  defp part1(list) do
    dive("shiny gold", list)
    |> Enum.sort()
    |> Enum.dedup()
    |> Enum.count()
    |> Kernel.-(1)
  end

  defp part2(list) do
    dive2("shiny gold", list)
    |> Kernel.-(1)
  end

  def run do
    {test_contains, test_inside} =
      test_input()
      |> output_to_list()
      |> remap()

    {test_contains2, _test_inside} =
      test_input2()
      |> output_to_list()
      |> remap()

    {contains, inside} =
      Advent.daily_input("2020", "07")
      |> output_to_list()
      |> remap()

    test_result1 = part1(test_inside)
    IO.puts("Solution to Test Part 1 (Should be 4): #{test_result1}")

    result1 = part1(inside)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2a = part2(test_contains)
    IO.puts("Solution to Test Part 2a (Should be 32): #{test_result2a}")

    test_result2b = part2(test_contains2)
    IO.puts("Solution to Test Part 2b (Should be 126): #{test_result2b}")

    result2 = part2(contains)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
