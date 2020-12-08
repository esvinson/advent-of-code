defmodule Advent.Day9 do
  alias Advent.Opcodes

  defp parse_file do
    Advent.daily_input(9)
    # "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    # "1102,34915192,34915192,7,4,7,99,0"
    # "104,1125899906842624,99"
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part1 do
    parse_file()
    |> Opcodes.list_to_map()
    |> Opcodes.registers_to_new_state()
    |> Map.put(:input, [1])
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
  end

  def part2 do
    parse_file()
    |> Opcodes.list_to_map()
    |> Opcodes.registers_to_new_state()
    |> Map.put(:input, [2])
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
  end
end
