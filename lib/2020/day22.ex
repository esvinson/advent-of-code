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

  def play_recursive({p1_cards, []}, _history), do: {:player1, p1_cards}
  def play_recursive({[], p2_cards}, _history), do: {:player2, p2_cards}

  def play_recursive(
        {[p1_card | p1_remaining] = p1_cards, [p2_card | p2_remaining] = p2_cards},
        history
      ) do
    card_set = {List.to_tuple(p1_cards), List.to_tuple(p2_cards)}

    Enum.member?(history, card_set)
    |> case do
      true ->
        {:player1, p1_cards}

      false ->
        if Enum.count(p1_remaining) >= p1_card && Enum.count(p2_remaining) >= p2_card do
          play_recursive(
            {p1_remaining |> Enum.take(p1_card), p2_remaining |> Enum.take(p2_card)},
            []
          )
          |> case do
            {:player1, _} ->
              play_recursive({p1_remaining ++ [p1_card, p2_card], p2_remaining}, [
                card_set | history
              ])

            {:player2, _} ->
              play_recursive({p1_remaining, p2_remaining ++ [p2_card, p1_card]}, [
                card_set | history
              ])
          end
        else
          if p1_card > p2_card do
            play_recursive({p1_remaining ++ [p1_card, p2_card], p2_remaining}, [
              card_set | history
            ])
          else
            play_recursive({p1_remaining, p2_remaining ++ [p2_card, p1_card]}, [
              card_set | history
            ])
          end
        end
    end
  end

  def part2(card_sets) do
    card_sets
    |> play_recursive([])
    |> calculate_score()
  end

  def run do
    test_input1 =
      test_input()
      |> parse()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 306): #{inspect(test_result1)}")

    test_result2 = part2(test_input1)
    IO.puts("Solution to Test Part 2 (Should be 291): #{inspect(test_result2)}")

    input =
      Advent.daily_input("2020", "22")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
