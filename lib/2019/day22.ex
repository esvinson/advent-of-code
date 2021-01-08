defmodule Aoc201922 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      cond do
        Regex.match?(~r/deal into new stack/, row) ->
          :reverse

        Regex.match?(~r/cut [\-\d]+/, row) ->
          {:cut, String.replace(row, "cut ", "") |> String.to_integer()}

        Regex.match?(~r/deal with increment [\d]+/, row) ->
          {:deal, String.replace(row, "deal with increment ", "") |> String.to_integer()}

        true ->
          {:error, "Unknown rule"}
      end
    end)
  end

  def do_work(rules, card_count) do
    starting_deck = 0..(card_count - 1) |> Enum.map(& &1)

    rules
    |> Enum.reduce(starting_deck, fn rule, deck ->
      case rule do
        :reverse ->
          Enum.reverse(deck)

        {:cut, size} ->
          Enum.concat(
            Enum.slice(deck, size..(card_count - 1)),
            Enum.slice(deck, 0..(size - 1))
          )

        {:deal, count} ->
          deck
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {card, index}, new_deck ->
            new_offset = rem(index * count, card_count)
            Map.put(new_deck, new_offset, card)
          end)
          |> Enum.sort(fn {key, _value}, {key2, _value2} -> key < key2 end)
          |> Enum.map(fn {_key, value} -> value end)
      end
    end)
  end

  def test_output(result) do
    result
    |> Enum.join(" ")
  end

  @spec test1 :: binary
  def test1 do
    """
    deal with increment 7
    deal into new stack
    deal into new stack
    """
    |> parse()
    |> do_work(10)
    |> test_output()
  end

  def test2 do
    """
    cut 6
    deal with increment 7
    deal into new stack
    """
    |> parse()
    |> do_work(10)
    |> test_output()
  end

  def test3 do
    """
    deal with increment 7
    deal with increment 9
    cut -2
    """
    |> parse()
    |> do_work(10)
    |> test_output()
  end

  def test4 do
    """
    deal into new stack
    cut -2
    deal with increment 7
    cut 8
    cut -4
    deal with increment 7
    cut 3
    deal with increment 9
    deal with increment 3
    cut -1
    """
    |> parse()
    |> do_work(10)
    |> test_output()
  end

  def part1 do
    Advent.daily_input("2019", "22")
    |> parse()
    |> do_work(10007)
    |> Enum.find_index(fn x -> x == 2019 end)
  end

  def run do
    Advent.output(&test1/0, "Test 1 Result:\n 0 3 6 9 2 5 8 1 4 7\n")
    Advent.output(&test2/0, "Test 2 Result:\n 3 0 7 4 1 8 5 2 9 6\n")
    Advent.output(&test3/0, "Test 2 Result:\n 6 3 0 7 4 1 8 5 2 9\n")
    Advent.output(&test4/0, "Test 2 Result:\n 9 2 5 8 1 4 7 0 3 6\n")
    Advent.output(&part1/0, "Part 1 Result: ")

    # Advent.output(&test2/0, "Part 2 Result: ")
  end
end
