defmodule Aoc202016 do
  def test_input,
    do: """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """

  def test_input2,
    do: """
    class: 0-1 or 4-19
    row: 0-5 or 8-19
    seat: 0-13 or 16-19

    your ticket:
    11,12,13

    nearby tickets:
    3,9,18
    15,1,5
    5,14,9
    """

  def parse_criteria(criteria) do
    criteria
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [key, valid] = row |> String.split(": ", trim: true)

      numbers =
        valid
        |> String.split(" or ")
        |> Enum.reduce(MapSet.new(), fn range_string, acc ->
          [startval, endval] =
            range_string
            |> String.split("-", trim: true)
            |> Enum.map(&String.to_integer(&1))

          Range.new(startval, endval)
          |> Enum.reduce(acc, fn val, subacc ->
            MapSet.put(subacc, val)
          end)
        end)

      {key, numbers}
    end)
  end

  def parse_your_ticket(ticket) do
    ticket
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> List.first()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def parse_other_tickets(ticket) do
    ticket
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(fn row ->
      row
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer(&1))
    end)
  end

  def parse_input(input) do
    [criteria, yours, others] =
      input
      |> String.split("\n\n", trim: true)

    %{
      criteria: parse_criteria(criteria),
      yours: parse_your_ticket(yours),
      others: parse_other_tickets(others)
    }
  end

  def part1(%{criteria: criteria, yours: _yours, others: others}) do
    valid_numbers =
      Enum.reduce(criteria, MapSet.new(), fn {_key, set}, acc ->
        MapSet.union(acc, set)
      end)

    others
    |> Enum.map(fn ticket ->
      ticket
      |> Enum.reduce(MapSet.new(), fn num, acc ->
        MapSet.put(acc, num)
      end)
    end)
    |> Enum.reduce([], fn ticket, acc ->
      MapSet.difference(ticket, valid_numbers)
      |> MapSet.to_list()
      |> Kernel.++(acc)
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  def reduce_list(list) do
    found =
      Enum.reduce(list, MapSet.new(), fn offset_list, acc ->
        if Enum.count(offset_list) == 1, do: MapSet.union(acc, offset_list), else: acc
      end)

    new_list =
      Enum.map(list, fn offset_list ->
        if Enum.count(offset_list) == 1,
          do: offset_list,
          else: MapSet.difference(offset_list, found)
      end)

    Enum.map(new_list, fn offset_list -> Enum.count(offset_list) end)
    |> Enum.max()
    |> case do
      1 ->
        new_list

      _ ->
        reduce_list(new_list)
    end
  end

  def part2(%{criteria: criteria, yours: yours, others: others}) do
    valid_numbers =
      Enum.reduce(criteria, MapSet.new(), fn {_key, set}, acc ->
        MapSet.union(acc, set)
      end)

    valid_others =
      Enum.filter(others, fn ticket ->
        ticket
        |> MapSet.new()
        |> MapSet.difference(valid_numbers)
        |> Enum.count() == 0
      end)

    all_keys = Enum.map(criteria, fn {key, _val} -> key end) |> MapSet.new()

    others_keys =
      Enum.map(valid_others, fn ticket ->
        Enum.map(ticket, fn field_value ->
          Enum.reduce(criteria, MapSet.new(), fn {key, valid_options}, acc ->
            if Enum.member?(valid_options, field_value), do: MapSet.put(acc, key), else: acc
          end)
        end)
      end)

    Range.new(0, Enum.count(yours) - 1)
    |> Enum.map(fn offset ->
      others_keys
      |> Enum.map(&Enum.at(&1, offset))
      |> Enum.reduce(all_keys, fn keys, acc ->
        MapSet.intersection(acc, keys)
      end)
    end)
    |> reduce_list()
    |> Enum.map(fn row ->
      row |> MapSet.to_list() |> List.first()
    end)
    |> Enum.zip(yours)
  end

  def run do
    test_input1 =
      test_input()
      |> parse_input()

    test_input2 =
      test_input2()
      |> parse_input()

    input =
      Advent.daily_input("2020", "16")
      |> parse_input()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 71): #{inspect(test_result1)}")

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{inspect(result1)}")

    test_result2 = part2(test_input2)
    IO.puts("Solution to Test Part 2: #{inspect(test_result2)}")

    result2 =
      part2(input)
      |> Enum.filter(fn {key, _val} ->
        key
        |> case do
          "departure " <> _rest -> true
          _ -> false
        end
      end)
      |> Enum.reduce(1, fn {_key, val}, acc ->
        acc * val
      end)

    IO.puts("Solution to Part 2: #{inspect(result2)}")
  end
end
