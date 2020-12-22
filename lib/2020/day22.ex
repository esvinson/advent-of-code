defmodule Aoc202022 do
  def test_input,
    do: """
    Player 1:
    9
    2
    6
    3
    1

    Player 2:
    5
    8
    4
    7
    10
    """

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn card_set ->
      card_set
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer(&1))
    end)
    |> List.to_tuple()
  end

  def play({[], cards}), do: {:player2, cards}
  def play({cards, []}), do: {:player1, cards}

  def play({[p1_card | p1_cards], [p2_card | p2_cards]}) do
    if p1_card > p2_card do
      play({p1_cards ++ [p1_card, p2_card], p2_cards})
    else
      play({p1_cards, p2_cards ++ [p2_card, p1_card]})
    end
  end

  def calculate_score({_player, cards}) do
    cards
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {card, index}, acc ->
      acc + card * (index + 1)
    end)
  end

  def part1(card_sets) do
    card_sets
    |> play()
    |> calculate_score()
  end

  def run do
    test_input1 =
      test_input()
      |> parse()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 306): #{inspect(test_result1)}")

    # test_result2 = part2(test_input1)
    # IO.puts("Solution to Test Part 2 (Should be 273): #{inspect(test_result2)}")

    input =
      Advent.daily_input("2020", "22")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    # result2 = part2(input)
    # IO.puts("Solution to Part 2: #{result2}")
  end
end
