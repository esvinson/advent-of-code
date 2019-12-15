defmodule Advent.Day13 do
  alias Advent.Opcodes

  defp parse_file do
    Advent.daily_input(13)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def build_tiles([], state), do: state

  def build_tiles([x, y, type | remaining], state) do
    new_state =
      state
      |> Map.put({x, y}, type)

    build_tiles(remaining, new_state)
  end

  def part1 do
    parse_file()
    |> Opcodes.list_to_map()
    |> Opcodes.registers_to_new_state()
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
    |> Enum.reverse()
    |> build_tiles(%{})
    |> Enum.filter(fn {_key, value} -> value == 2 end)
    |> Enum.count()
  end
end
