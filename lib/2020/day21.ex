defmodule Aoc202021 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [ingredients, alergens] =
        row
        |> String.replace(~r/\)$/, "")
        |> String.split(" (", parts: 2, trim: true)

      {String.split(ingredients, " ", trim: true),
       alergens |> String.replace("contains ", "") |> String.split(", ", trim: true)}
    end)
  end

  def part1(lines) do
    all_ingredient_counts =
      Enum.reduce(lines, [], fn {ingredients, _alergens}, acc ->
        ingredients ++ acc
      end)
      |> Enum.frequencies()

    ingredient_keys = Map.keys(all_ingredient_counts) |> MapSet.new()

    all_alergens =
      lines
      |> Enum.reduce(%{}, fn {ingredients, alergens}, acc ->
        Enum.reduce(alergens, acc, fn alergen, alergen_acc ->
          Map.get(alergen_acc, alergen)
          |> case do
            nil ->
              Map.put(alergen_acc, alergen, MapSet.new(ingredients))

            current ->
              Map.put(alergen_acc, alergen, MapSet.intersection(current, MapSet.new(ingredients)))
          end
        end)
      end)
      |> Enum.reduce(MapSet.new(), fn {_key, alergen}, acc ->
        MapSet.union(acc, alergen)
      end)

    MapSet.difference(ingredient_keys, all_alergens)
    |> MapSet.to_list()
    |> Enum.reduce(0, fn ingredient, acc ->
      acc + Map.get(all_ingredient_counts, ingredient, 0)
    end)
  end

  def eliminate_duplicates([], _used, output), do: output

  def eliminate_duplicates([{alergen, options} | alergen_list], used, output) do
    options
    |> MapSet.size()
    |> case do
      1 ->
        eliminate_duplicates(
          alergen_list,
          MapSet.union(used, options),
          Map.put(output, alergen, List.first(MapSet.to_list(options)))
        )

      _ ->
        eliminate_duplicates(
          alergen_list ++ [{alergen, MapSet.difference(options, used)}],
          used,
          output
        )
    end
  end

  def part2(lines) do
    alergen_map =
      lines
      |> Enum.reduce(%{}, fn {ingredients, alergens}, acc ->
        Enum.reduce(alergens, acc, fn alergen, alergen_acc ->
          Map.get(alergen_acc, alergen)
          |> case do
            nil ->
              Map.put(alergen_acc, alergen, MapSet.new(ingredients))

            current ->
              Map.put(alergen_acc, alergen, MapSet.intersection(current, MapSet.new(ingredients)))
          end
        end)
      end)
      |> Map.to_list()
      |> eliminate_duplicates(MapSet.new(), %{})

    keys = alergen_map |> Map.keys() |> Enum.sort()

    Enum.map(keys, fn key -> alergen_map[key] end)
    |> Enum.join(",")
  end

  def run do
    test_input1 =
      test_input()
      |> parse()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 5): #{inspect(test_result1)}")

    input =
      Advent.daily_input("2020", "21")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{inspect(result1)}")

    test_result2 = part2(test_input1)
    IO.puts("Solution to Test Part 2 (Should be mxmxvkd,sqjhc,fvjkl): #{inspect(test_result2)}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{inspect(result2)}")
  end

  def test_input,
    do: """
    mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
    trh fvjkl sbzzf mxmxvkd (contains dairy)
    sqjhc fvjkl (contains soy)
    sqjhc mxmxvkd sbzzf (contains fish)
    """
end
