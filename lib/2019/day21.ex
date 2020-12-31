defmodule Aoc201921 do
  alias Advent.Opcodes

  def do_work(input, instructions) do
    output =
      input
      |> Opcodes.parse_input()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()
      |> Map.put(:input, instructions)
      |> Opcodes.parse()
      |> elem(1)
      |> Map.get(:output)

    answer =
      output
      |> List.first()

    if output > 255 do
      output |> Enum.drop(1) |> Enum.reverse() |> IO.puts()
      answer
    else
      to_string(output |> Enum.reverse())
    end

    # |> Enum.reverse()
  end

  def part1 do
    instructions =
      """
      NOT A J
      NOT B T
      OR T J
      NOT C T
      OR T J
      AND D J
      WALK

      """
      |> to_charlist()

    Advent.daily_input("2019", "21")
    |> do_work(instructions)
  end

  def part2 do
    instructions =
      """
      NOT A J
      NOT B T
      OR T J
      NOT C T
      OR T J
      NOT C T
      OR T J
      AND D J
      NOT E T
      NOT T T
      OR H T
      AND T J
      RUN

      """
      |> to_charlist()

    Advent.daily_input("2019", "21")
    |> do_work(instructions)
  end

  def run do
    # Advent.output(&test1_part1/0, "Test Part 1 Result (Should be 23): ")
    # Advent.output(&test2_part1/0, "Test Part 1 Result (Should be 58): ")
    Advent.output(&part1/0, "Part 1 Result: ")
    # Advent.output(&test1_part2/0, "Test Part 2 Result (Should be 26): ")
    # Advent.output(&test2_part2/0, "Test Part 2 Result (Should be 396): ")
    Advent.output(&part2/0, "Part 2 Result: ")
  end
end
