defmodule Aoc202304 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [card, rest] = String.split(row, ": ", trim: true)
      card = Regex.run(~r/(\d+)/, card) |> List.last()
      [left, right] = String.split(rest, " | ", trim: true)
      left = String.split(left, " ", trim: true)
      right = String.split(right, " ", trim: true)
      {String.to_integer(card), {MapSet.new(left), MapSet.new(right)}}
    end)
  end

  defp part1(cards) do
    cards
    |> Enum.map(fn {_card, {left, right}} ->
      val = MapSet.intersection(left, right) |> Enum.count()
      if val > 0, do: 2 ** (val - 1), else: 0
    end)
    |> Enum.sum()
  end

  defp get_cache(map, cache, card) do
    Map.get(cache, card)
    |> case do
      nil ->
        {left, right} = Map.get(map, card)
        val = MapSet.intersection(left, right) |> Enum.to_list() |> Enum.count()

        new_card_numbers =
          if val > 0, do: Range.to_list(Range.new(card + 1, card + val)), else: []

        {Map.put(cache, card, new_card_numbers), new_card_numbers}

      val ->
        {cache, val}
    end
  end

  defp process_cards(_map, _cache, [], output), do: output |> Map.values() |> Enum.sum()

  defp process_cards(map, cache, [card | rest], output) do
    {cache, new_cards} = get_cache(map, cache, card)
    remaining = new_cards ++ rest
    output = Map.update(output, card, 1, fn x -> x + 1 end)
    process_cards(map, cache, remaining, output)
  end

  defp part2(cards) do
    card_map = Map.new(cards)
    card_list = Map.keys(card_map) |> Enum.sort()
    process_cards(card_map, %{}, card_list, %{})
  end

  def run() do
    test_input =
      """
      Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
      Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
      Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
      Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
      Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
      Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
      """
      |> parse()

    input =
      Advent.daily_input("2023", "04")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
