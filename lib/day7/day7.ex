defmodule Advent.Day7 do
  alias Advent.Opcodes

  defp parse_file do
    File.read!("lib/day7/day7.input")
    # "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
    # "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    # "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def list_to_map(lst) do
    Enum.reduce(Enum.with_index(lst), %{}, fn {val, key}, acc ->
      Map.put(acc, key, val)
    end)
  end

  defp validate(a, b, c, d, e) do
    if length([a, b, c, d, e]) == length(Enum.uniq([a, b, c, d, e])),
      do: [{a, b, c, d, e}],
      else: []
  end

  def build_sets(a, b, c, d, 5), do: build_sets(a, b, c, d + 1, 0)
  def build_sets(a, b, c, 5, _), do: build_sets(a, b, c + 1, 0, 0)
  def build_sets(a, b, 5, _, _), do: build_sets(a, b + 1, 0, 0, 0)
  def build_sets(a, 5, _, _, _), do: build_sets(a + 1, 0, 0, 0, 0)
  def build_sets(5, _, _, _, _), do: []

  def build_sets(a, b, c, d, e) do
    validate(a, b, c, d, e) ++ build_sets(a, b, c, d, e + 1)
  end

  def build_sets_part2(a, b, c, d, 10), do: build_sets_part2(a, b, c, d + 1, 5)
  def build_sets_part2(a, b, c, 10, _), do: build_sets_part2(a, b, c + 1, 5, 5)
  def build_sets_part2(a, b, 10, _, _), do: build_sets_part2(a, b + 1, 5, 5, 5)
  def build_sets_part2(a, 10, _, _, _), do: build_sets_part2(a + 1, 5, 5, 5, 5)
  def build_sets_part2(10, _, _, _, _), do: []

  def build_sets_part2(a, b, c, d, e) do
    validate(a, b, c, d, e) ++ build_sets_part2(a, b, c, d, e + 1)
  end

  def part1 do
    initial_state =
      parse_file()
      |> list_to_map()
      |> Opcodes.registers_to_new_state()

    build_sets(0, 0, 0, 0, 0)
    |> Enum.reduce([], fn {a, b, c, d, e}, acc ->
      val =
        initial_state
        |> Map.put(:input, [a, :output, b, :output, c, :output, d, :output, e, :output])
        |> Opcodes.parse()
        |> elem(1)
        |> Map.put(:instruction_pointer, 0)
        |> Opcodes.parse()
        |> elem(1)
        |> Map.put(:instruction_pointer, 0)
        |> Opcodes.parse()
        |> elem(1)
        |> Map.put(:instruction_pointer, 0)
        |> Opcodes.parse()
        |> elem(1)
        |> Map.put(:instruction_pointer, 0)
        |> Opcodes.parse()
        |> elem(1)
        |> Map.get(:output)
        |> Enum.at(0)

      [val] ++ acc
    end)
    |> Enum.max()
  end

  defp run_state(%{input: input} = state1, state2, state3, state4, %{output: output} = state5, 0) do
    {_, new_state1} =
      state1
      |> Map.put(:input, input ++ last_output(output))
      |> Opcodes.parse()

    output |> Enum.at(0) |> IO.inspect(label: "1 ===>")

    run_state(new_state1, state2, state3, state4, state5, 1)
  end

  defp run_state(%{output: output} = state1, %{input: input} = state2, state3, state4, state5, 1) do
    {_, new_state2} =
      state2
      |> Map.put(:input, input ++ last_output(output))
      |> Opcodes.parse()

    output |> Enum.at(0) |> IO.inspect(label: "2 ===>")

    run_state(state1, new_state2, state3, state4, state5, 2)
  end

  defp run_state(state1, %{output: output} = state2, %{input: input} = state3, state4, state5, 2) do
    {_, new_state3} =
      state3
      |> Map.put(:input, input ++ last_output(output))
      |> Opcodes.parse()

    output |> Enum.at(0) |> IO.inspect(label: "3 ===>")

    run_state(state1, state2, new_state3, state4, state5, 3)
  end

  defp run_state(state1, state2, %{output: output} = state3, %{input: input} = state4, state5, 3) do
    {_, new_state4} =
      state4
      |> Map.put(:input, input ++ last_output(output))
      |> Opcodes.parse()

    output |> Enum.at(0) |> IO.inspect(label: "4 ===>")

    run_state(state1, state2, state3, new_state4, state5, 4)
  end

  defp run_state(state1, state2, state3, %{output: output} = state4, %{input: input} = state5, 4) do
    state5
    |> Map.put(:input, input ++ last_output(output))
    |> Opcodes.parse()
    |> case do
      {:halt, new_state5} ->
        new_state5 |> Map.get(:output) |> Enum.at(0) |> IO.inspect(label: "DONE ===>")
        new_state5

      {:cont, new_state5} ->
        run_state(state1, state2, state3, state4, new_state5, 0)
    end
  end

  defp last_output([]), do: []

  defp last_output(list) do
    val =
      list
      |> Enum.at(0)

    [val]
  end

  def part2 do
    initial_state =
      parse_file()
      |> list_to_map()
      |> Opcodes.registers_to_new_state()

    build_sets_part2(5, 5, 5, 5, 5)
    |> Enum.reduce([], fn {a, b, c, d, e}, acc ->
      val =
        run_state(
          initial_state |> Map.put(:input, [a]),
          initial_state |> Map.put(:input, [b]),
          initial_state |> Map.put(:input, [c]),
          initial_state |> Map.put(:input, [d]),
          initial_state |> Map.put(:input, [e]) |> Map.put(:output, [0]),
          0
        )
        |> Map.get(:output)
        |> Enum.at(0)

      [val] ++ acc
    end)
    |> Enum.max()
  end
end
