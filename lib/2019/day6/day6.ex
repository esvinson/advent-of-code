defmodule Advent.Day6 do
  defp parse_file do
    File.read!("lib/day6/day6.input")
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn row, acc ->
      [parent, node] = String.split(row, ")")
      Map.put(acc, node, parent)
    end)
  end

  defp count_upstream(orbits, key) do
    Map.get(orbits, key)
    |> case do
      nil -> 1
      new_key -> 1 + count_upstream(orbits, new_key)
    end
  end

  defp get_upstream(_orbits, nil, context) do
    context
  end

  defp get_upstream(orbits, key, context) do
    parent = Map.get(orbits, key)
    get_upstream(orbits, parent, context ++ [parent])
  end

  def part1 do
    orbits = parse_file()

    orbits
    |> Enum.map(fn {_key, orbit} ->
      count_upstream(orbits, orbit)
    end)
    |> Enum.sum()
  end

  def part2 do
    orbits = parse_file()
    you = get_upstream(orbits, "YOU", [])
    santa = get_upstream(orbits, "SAN", [])

    {left, right} =
      you
      |> Enum.reduce_while(nil, fn youx, _acc ->
        Enum.find_index(santa, fn santax ->
          youx == santax
        end)
        |> case do
          nil ->
            {:cont, nil}

          santa_offset ->
            you_offset = Enum.find_index(you, fn x -> x == youx end)
            {:halt, {you_offset, santa_offset}}
        end
      end)

    left + right
  end
end
