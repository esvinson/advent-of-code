defmodule Advent.Day5 do
  alias Advent.Opcodes

  defp parse_file do
    File.read!("lib/day5/day5.input")
    # "1101,100,-1,4,0"
    # "1002,4,3,4,33"
    # "3,9,8,9,10,9,4,9,99,-1,8"
    # "3,9,7,9,10,9,4,9,99,-1,8"
    # "3,3,1108,-1,8,3,4,3,99"
    # "3,3,1107,-1,8,3,4,3,99"
    # "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
    # "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
    # "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def list_to_map(lst) do
    Enum.reduce(Enum.with_index(lst), %{}, fn {val, key}, acc ->
      Map.put(acc, key, val)
    end)
  end

  def part1 do
    parse_file()
    |> list_to_map()
    |> Opcodes.registers_to_new_state()
    |> put_in([:input], [1])
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
    |> hd()
  end

  def part2 do
    parse_file()
    |> list_to_map()
    |> Opcodes.registers_to_new_state()
    |> put_in([:input], [5])
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
    |> hd()
  end
end
