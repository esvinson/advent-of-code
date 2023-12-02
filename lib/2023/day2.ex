defmodule Aoc202302 do
  defp parseRound(set) do
    set
    |> String.split(", ", trim: true)
    |> Enum.reduce(%{}, fn subset, acc ->
      key =
        cond do
          String.contains?(subset, "red") ->
            :red

          String.contains?(subset, "green") ->
            :green

          String.contains?(subset, "blue") ->
            :blue
        end

      val = subset |> String.replace(~r/[^\d]/, "") |> String.to_integer()
      Map.put(acc, key, val)
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn row, acc ->
      [_, id, results] = Regex.run(~r/Game (\d+): (.*)/, row)

      output = results |> String.split("; ", trim: true) |> Enum.map(&parseRound(&1))

      Map.put(acc, String.to_integer(id), output)
    end)
  end

  defp is_ok?({:red, x}) when x <= 12, do: true
  defp is_ok?({:red, _}), do: false
  defp is_ok?({:green, x}) when x <= 13, do: true
  defp is_ok?({:green, _}), do: false
  defp is_ok?({:blue, x}) when x <= 14, do: true
  defp is_ok?({:blue, _}), do: false

  def part1(games) do
    games
    |> Enum.map(fn {id, round} ->
      val =
        round
        |> Enum.reduce(true, fn set, acc ->
          set_ok =
            set
            |> Enum.map(&is_ok?(&1))
            |> Enum.all?(& &1)

          acc && set_ok
        end)

      {id, val}
    end)
    |> Enum.reduce(0, fn {id, is_good?}, acc ->
      if is_good?, do: acc + id, else: acc
    end)
  end

  defp use_greatest({:red, x}, %{red: y} = acc) when x > y, do: Map.put(acc, :red, x)
  defp use_greatest({:green, x}, %{green: y} = acc) when x > y, do: Map.put(acc, :green, x)
  defp use_greatest({:blue, x}, %{blue: y} = acc) when x > y, do: Map.put(acc, :blue, x)
  defp use_greatest(_, acc), do: acc

  def part2(games) do
    games
    |> Enum.map(fn {_id, round} ->
      %{red: red, green: green, blue: blue} =
        round
        |> Enum.reduce(%{red: 0, green: 0, blue: 0}, fn set, acc ->
          Enum.reduce(set, acc, fn {color, val}, acc -> use_greatest({color, val}, acc) end)
        end)

      red * green * blue
    end)
    |> Enum.sum()
  end

  def run() do
    test_input =
      """
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
      """
      |> parse()

    input =
      Advent.daily_input("2023", "02")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
