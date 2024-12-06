defmodule Aoc202405 do
  defp parse(input) do
    [rules_raw, updates_raw] =
      input
      |> String.split("\n\n", trim: true)

    rules =
      rules_raw
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn row, acc ->
        [left, right] = String.split(row, "|", trim: true) |> Enum.map(&String.to_integer/1)

        Map.update(acc, right, MapSet.new([left]), fn current ->
          MapSet.put(current, left)
        end)
      end)

    updates =
      updates_raw
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        row
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

    %{rules: rules, updates: updates}
  end

  defp validate([_x], _rules), do: true

  defp validate([x | update], rules) do
    up = MapSet.new(update)
    empty = MapSet.new([])

    if update == [] and is_nil(Map.get(rules, x)) do
      true
    else
      if MapSet.intersection(Map.get(rules, x, MapSet.new([])), up) != empty do
        false
      else
        validate(update, rules)
      end
    end
  end

  defp part1(%{rules: rules, updates: updates}) do
    Enum.reduce(updates, [], fn update, acc ->
      if validate(update, rules) do
        [Enum.at(update, div(Enum.count(update), 2))] ++ acc
      else
        acc
      end
    end)
    |> Enum.sum()
  end

  defp sort(update, rules) do
    empty = MapSet.new([])

    Enum.reduce(update, [], fn x, acc ->
      if acc == [] do
        [x]
      else
        check = Map.get(rules, x, MapSet.new([]))

        if MapSet.intersection(check, MapSet.new(acc)) != empty do
          {was_found, output} =
            Enum.reduce(acc, {false, []}, fn y, {found, acc2} ->
              if found do
                {true, acc2 ++ [y]}
              else
                if MapSet.intersection(check, MapSet.new([y])) ==
                     empty do
                  {true, acc2 ++ [x, y]}
                else
                  {false, acc2 ++ [y]}
                end
              end
            end)

          if was_found do
            output
          else
            output ++ [x]
          end
        else
          [x] ++ acc
        end
      end
    end)
  end

  defp part2(%{rules: rules, updates: updates}) do
    Enum.reduce(updates, [], fn update, acc ->
      if validate(update, rules) do
        acc
      else
        sorted = sort(update, rules)
        [Enum.at(sorted, div(Enum.count(sorted), 2))] ++ acc
      end
    end)
    |> Enum.sum()
  end

  def run() do
    test_input =
      """
      47|53
      97|13
      97|61
      97|47
      75|29
      61|13
      75|53
      29|13
      97|29
      53|29
      61|53
      97|53
      61|29
      47|13
      75|47
      97|75
      47|61
      75|61
      47|29
      75|13
      53|13

      75,47,61,53,29
      97,61,53,29,13
      75,29,13
      75,97,47,61,53
      61,13,29
      97,13,75,29,47
      """
      |> parse()

    input =
      Advent.daily_input("2024", "05")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
