defmodule Aoc202211 do
  def convert_types(monkey) do
    monkey
    |> Map.update(
      "items",
      [],
      &(String.split(&1, ", ") |> Enum.map(fn x -> String.to_integer(x) end))
    )
    |> Map.update("divisor", 0, &String.to_integer/1)
    |> Map.update("monkey_id", 0, &String.to_integer/1)
    |> Map.update("true", 0, &String.to_integer/1)
    |> Map.update("false", 0, &String.to_integer/1)
  end

  def parse_monkey(monkey_string) do
    {:ok, regex} =
      "Monkey (?<monkey_id>\\d+):\\n\\W+Starting items: (?<items>[\\d, ]+)\\n\\W+Operation: new = (?<operation>.*)\\n\\W+Test: divisible by (?<divisor>.*)\\n\\W+If true: throw to monkey (?<true>\\d+)\\n\\W+If false: throw to monkey (?<false>\\d+)"
      |> Regex.compile()

    regex
    |> Regex.named_captures(monkey_string)
    |> convert_types
  end

  def monkey_map(monkeys) do
    Enum.reduce(monkeys, %{}, fn monkey, acc ->
      Map.put(acc, Map.get(monkey, "monkey_id", 999), monkey)
    end)
  end

  def parse(input) do
    monkeys =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&parse_monkey/1)

    total_monkeys = length(monkeys)
    {total_monkeys, monkey_map(monkeys)}
  end

  def worry(val, "old * old"), do: val * val
  def worry(val, "old * " <> multi), do: val * String.to_integer(multi)
  def worry(val, "old + " <> adder), do: val + String.to_integer(adder)

  def relief(val, false), do: div(val, 3)
  def relief(val, lcm), do: rem(val, lcm)

  def toss(monkeys, [], _divisor, _iftrue, _iffalse), do: monkeys

  def toss(monkeys, [item | items], divisor, iftrue, iffalse) do
    target = if rem(item, divisor) == 0, do: iftrue, else: iffalse
    monkey = Map.get(monkeys, target)
    updated_monkey = Map.update(monkey, "items", [item], fn item_list -> [item] ++ item_list end)

    Map.put(monkeys, target, updated_monkey)
    |> toss(items, divisor, iftrue, iffalse)
  end

  def do_round({total, monkeys}, do_lcm \\ false) do
    Enum.reduce(0..(total - 1), monkeys, fn x, monkeys ->
      %{
        "divisor" => divisor,
        "true" => iftrue,
        "false" => iffalse,
        "items" => items,
        "operation" => operation
      } = monkey = Map.get(monkeys, x)

      item_count = length(items)

      new_items =
        items
        |> Enum.map(&worry(&1, operation))
        |> Enum.map(&relief(&1, do_lcm))

      updated_monkey =
        monkey
        |> Map.update("inspections", item_count, fn n -> n + item_count end)
        |> Map.put("items", [])

      Map.put(monkeys, x, updated_monkey)
      |> toss(new_items, divisor, iftrue, iffalse)
    end)
  end

  def part1({total, monkeys}) do
    [x, y] =
      monkeys
      |> Stream.iterate(fn current_monkeys ->
        do_round({total, current_monkeys})
      end)
      |> Stream.drop(20)
      |> Enum.take(1)
      |> List.first()
      |> Enum.reduce([], fn {_index, monkey}, acc ->
        [Map.get(monkey, "inspections", 0)] ++ acc
      end)
      |> Enum.sort(:desc)
      |> Enum.take(2)

    x * y
  end

  defp get_inspections(monkeys) do
    monkeys
    |> Enum.reduce([], fn {_index, monkey}, acc ->
      [Map.get(monkey, "inspections", 0)] ++ acc
    end)
  end

  defp get_divisors(monkeys) do
    monkeys
    |> Enum.reduce([], fn {_index, monkey}, acc ->
      [Map.get(monkey, "divisor", 0)] ++ acc
    end)
  end

  def part2({total, monkeys}) do
    divisors = get_divisors(monkeys)
    lcm = Advent.Algorithms.lcm(divisors)

    [x, y] =
      monkeys
      |> Stream.iterate(fn current_monkeys ->
        do_round({total, current_monkeys}, lcm)
      end)
      |> Stream.drop(10000)
      |> Enum.take(1)
      |> List.first()
      |> get_inspections()
      |> Enum.sort(:desc)
      |> Enum.take(2)

    x * y
  end

  def run do
    test_input = Advent.daily_input("2022", "11.test") |> parse()
    input = Advent.daily_input("2022", "11") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
