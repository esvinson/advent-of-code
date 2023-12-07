defmodule Aoc202307 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [cards, bet] = String.split(row, " ", trim: true)
      bet = String.to_integer(bet)
      cards = String.split(cards, "", trim: true)
      {cards, bet}
    end)
  end

  defp map(:five_of_a_kind), do: 7
  defp map(:four_of_a_kind), do: 6
  defp map(:full_house), do: 5
  defp map(:three_of_a_kind), do: 4
  defp map(:two_pair), do: 3
  defp map(:two_of_a_kind), do: 2
  defp map(:high_card), do: 1

  defp map("A"), do: 14
  defp map("K"), do: 13
  defp map("Q"), do: 12
  defp map("J"), do: 11
  defp map("T"), do: 10
  defp map(x), do: String.to_integer(x)

  defp map2("J"), do: 1
  defp map2(x), do: map(x)

  ## overengineered and used poker sorting instead, this is incorrect.
  # hands
  # |> Enum.map(fn {cards, bet} ->
  #   result =
  #     cards
  #     |> Enum.map(&map/1)
  #     |> Enum.frequencies()
  #     |> Enum.reduce([], fn {card, freq}, acc ->
  #       [{freq, card}] ++ acc
  #     end)
  #     |> Enum.sort()
  #     |> Enum.reverse()
  #     |> Enum.reduce({}, fn {freq, card}, acc ->
  #       acc
  #       |> Tuple.append(freq)
  #       |> Tuple.append(card)
  #     end)

  #   {result, bet}
  # end)
  # |> Enum.sort(fn
  #   # 2 of a kind
  #   {{2, _, 2, _, 1, _}, _bet}, {{2, _, 1, _, 1, _, 1, _}, _bet2} ->
  #     false

  #   # full house
  #   {{3, _, 2, _}, _bet}, {{3, _, 1, _, 1, _}, _bet2} ->
  #     false

  #   # 2 of a kind
  #   {{2, _, 1, _, 1, _, 1, _}, _bet2}, {{2, _, 2, _, 1, _}, _bet} ->
  #     true

  #   # full house
  #   {{3, _, 1, _, 1, _}, _bet2}, {{3, _, 2, _}, _bet} ->
  #     true

  #   {cards, _bet}, {cards2, _bet2} ->
  #     Tuple.to_list(cards) < Tuple.to_list(cards2)
  # end)
  # |> IO.inspect(label: "====>", limit: :infinity)
  # |> Enum.with_index()
  # |> Enum.reduce(0, fn {{cards, bet}, rank}, acc ->
  #   IO.inspect({cards, {rank + 1, bet}})
  #   acc + (rank + 1) * bet
  # end)

  defp part1(hands) do
    hands
    |> Enum.map(fn {cards, bet} ->
      type =
        cards
        |> Enum.map(&map/1)
        |> Enum.frequencies()
        |> Enum.reduce([], fn {card, freq}, acc ->
          [{freq, card}] ++ acc
        end)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.reduce({}, fn {freq, card}, acc ->
          acc
          |> Tuple.append(freq)
          |> Tuple.append(card)
        end)
        |> case do
          {5, _} -> :five_of_a_kind
          {4, _, 1, _} -> :four_of_a_kind
          {3, _, 2, _} -> :full_house
          {3, _, 1, _, 1, _} -> :three_of_a_kind
          {2, _, 2, _, 1, _} -> :two_pair
          {2, _, 1, _, 1, _, 1, _} -> :two_of_a_kind
          _ -> :high_card
        end
        |> map()

      original_cards = cards |> Enum.map(&map/1)

      {type, original_cards, bet}
    end)
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_type, _cards, bet}, rank}, acc ->
      acc + (rank + 1) * bet
    end)
  end

  defp use_jokers({0, cards}), do: cards
  defp use_jokers({5, _cards}), do: {5, 1}

  defp use_jokers({x, cards}) do
    [y | remaining] = Tuple.to_list(cards)
    List.to_tuple([y + x] ++ remaining)
  end

  defp part2(hands) do
    hands
    |> Enum.map(fn {cards, bet} ->
      type =
        cards
        |> Enum.map(&map2/1)
        |> Enum.frequencies()
        |> Enum.reduce([], fn {card, freq}, acc ->
          card = if card == 11, do: 1, else: card
          [{freq, card}] ++ acc
        end)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.reduce({0, {}}, fn {freq, card}, {jokers, cards} ->
          if card == 1 do
            {jokers + freq, cards}
          else
            {jokers,
             cards
             |> Tuple.append(freq)
             |> Tuple.append(card)}
          end
        end)
        |> use_jokers()
        |> case do
          {5, _} -> :five_of_a_kind
          {4, _, 1, _} -> :four_of_a_kind
          {3, _, 2, _} -> :full_house
          {3, _, 1, _, 1, _} -> :three_of_a_kind
          {2, _, 2, _, 1, _} -> :two_pair
          {2, _, 1, _, 1, _, 1, _} -> :two_of_a_kind
          _ -> :high_card
        end
        |> map()

      original_cards = cards |> Enum.map(&map2/1)

      {type, original_cards, bet}
    end)
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_type, _cards, bet}, rank}, acc ->
      acc + (rank + 1) * bet
    end)
  end

  def run() do
    test_input =
      """
      32T3K 765
      T55J5 684
      KK677 28
      KTJJT 220
      QQQJA 483
      """
      |> parse()

    input =
      Advent.daily_input("2023", "07")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
