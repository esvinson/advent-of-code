defmodule Advent.Day8 do
  defp parse_file do
    File.read!("lib/day8/day8.input")
    # "123456789012"
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.chunk_every(25 * 6)
    |> Enum.map(&Enum.join/1)
  end

  def part1 do
    checksum_layer =
      parse_file()
      |> Enum.map(fn layer ->
        layer
        |> String.graphemes()
        |> Enum.sort()
        |> Enum.chunk_by(& &1)
        |> Enum.reduce(%{}, fn row, acc ->
          Map.put(acc, String.to_integer(Enum.at(row, 0)), Enum.count(row))
        end)
      end)
      |> Enum.min_by(fn row ->
        Map.get(row, 0, 0)
      end)

    Map.get(checksum_layer, 1) * Map.get(checksum_layer, 2)
  end

  def part2 do
    parse_file()
    |> Enum.reduce(fn layer, state ->
      0..(String.length(state) - 1)
      |> Enum.reduce(state, fn offset, new_state ->
        String.at(new_state, offset)
        |> case do
          "2" ->
            String.slice(new_state, 0, offset) <>
              String.at(layer, offset) <>
              String.slice(new_state, offset + 1, String.length(new_state) - offset - 1)

          _ ->
            new_state
        end
      end)
    end)
    |> String.split("", trim: true)
    |> Enum.map(&String.replace(&1, "1", "#"))
    |> Enum.map(&String.replace(&1, "0", " "))
    |> Enum.chunk_every(25)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&IO.puts/1)
  end
end
