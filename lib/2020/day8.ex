defmodule Aoc202008 do
  defp test_input,
    do: """
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    """

  defp parse_code(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc ->
      [opcode, value] = String.split(line, " ", trim: true)
      Map.put(acc, index, %{opcode: opcode, value: String.to_integer(value), executions: 0})
    end)
  end

  defp increment_executions(code, offset) do
    current =
      code
      |> Map.get(offset)

    new =
      current
      |> Map.put(:executions, current.executions + 1)

    Map.put(code, offset, new)
  end

  defp change_opcode(code, offset, new_opcode) do
    new =
      code
      |> Map.get(offset)
      |> Map.put(:opcode, new_opcode)

    Map.put(code, offset, new)
  end

  defp execute(code, offset, accumulator \\ 0) do
    Map.get(code, offset)
    |> case do
      %{opcode: op, executions: execs, value: val} ->
        if execs > 0 do
          {:infinite, accumulator}
        else
          case op do
            "nop" ->
              execute(increment_executions(code, offset), offset + 1, accumulator)

            "acc" ->
              execute(increment_executions(code, offset), offset + 1, accumulator + val)

            "jmp" ->
              execute(increment_executions(code, offset), offset + val, accumulator)
          end
        end

      nil ->
        {:complete, accumulator}
    end
  end

  defp part1(code) do
    {:infinite, test_result} = execute(code, 0)
    test_result
  end

  defp part2(code) do
    Map.keys(code)
    |> Enum.reduce_while(nil, fn key, _acc ->
      Map.get(code, key)
      |> Map.get(:opcode)
      |> case do
        "jmp" ->
          change_opcode(code, key, "nop")
          |> execute(0, 0)

        "nop" ->
          change_opcode(code, key, "jmp")
          |> execute(0, 0)

        _ ->
          {:infinite, 0}
      end
      |> case do
        {:infinite, _} ->
          {:cont, nil}

        {:complete, accumulator} ->
          {:halt, accumulator}
      end
    end)
  end

  def run do
    test_code =
      test_input()
      |> parse_code()

    code =
      Advent.daily_input("2020", "08")
      |> parse_code()

    test_result1 = part1(test_code)
    IO.puts("Solution to Test Part 1 (Should be 5): #{test_result1}")

    result1 = part1(code)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2 = part2(test_code)
    IO.puts("Solution to Test Part 2 (Should be 8): #{test_result2}")

    result2 = part2(code)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
