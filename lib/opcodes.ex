defmodule Advent.Opcodes do
  require Logger

  defp get_param(
         %{registers: registers, relative_base: relative_base},
         instruction_pointer,
         params,
         offset
       ) do
    Enum.at(params, offset)
    |> case do
      2 ->
        Map.get(registers, relative_base + Map.get(registers, instruction_pointer, 0))

      1 ->
        Map.get(registers, instruction_pointer, 0)

      0 ->
        Map.get(registers, Map.get(registers, instruction_pointer, 0), 0)
    end
  end

  defp get_position_param(
         %{registers: registers, relative_base: relative_base},
         instruction_pointer,
         params,
         offset
       ) do
    Enum.at(params, offset)
    |> case do
      2 ->
        relative_base + Map.get(registers, instruction_pointer, 0)

      1 ->
        instruction_pointer

      0 ->
        Map.get(registers, instruction_pointer, 0)
    end
  end

  # defp operation(opcode, state, instruction_pointer),
  #   do: operation(opcode, state, [0, 0, 0], instruction_pointer)

  defp operation(
         1,
         %{
           registers: registers,
           instruction_pointer: instruction_pointer
         } = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      },#{Map.get(registers, instruction_pointer + 2)},#{
        Map.get(registers, instruction_pointer + 3)
      }"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    param2 = get_param(state, instruction_pointer + 2, param_codes, 1)
    val = param1 + param2
    position = get_position_param(state, instruction_pointer + 3, param_codes, 2)

    Logger.debug("Set state #{position} to #{val} (#{param1} + #{param2})")

    put_in(state[:registers][position], val)
    |> Map.put(:instruction_pointer, instruction_pointer + 4)
    |> parse()
  end

  defp operation(
         2,
         %{
           registers: registers,
           instruction_pointer: instruction_pointer
         } = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      },#{Map.get(registers, instruction_pointer + 2)},#{
        Map.get(registers, instruction_pointer + 3)
      }"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    param2 = get_param(state, instruction_pointer + 2, param_codes, 1)
    val = param1 * param2
    position = get_position_param(state, instruction_pointer + 3, param_codes, 2)

    Logger.debug("Set state #{position} to #{val} (#{param1} x #{param2})")

    put_in(state[:registers][position], val)
    |> Map.put(:instruction_pointer, instruction_pointer + 4)
    |> parse()
  end

  defp operation(3, %{input: []} = state, _param_codes), do: {:cont, state}

  defp operation(
         3,
         %{
           registers: registers,
           input: input,
           output: output,
           instruction_pointer: instruction_pointer
         } = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      }"
    )

    position = get_position_param(state, instruction_pointer + 1, param_codes, 0)

    [val | remaining] = input
    val = if val == :output, do: Enum.at(output, 0) || 0, else: val

    Logger.debug("Set state #{position} to #{val}")

    state
    |> put_in([:registers, position], val)
    |> Map.put(:input, remaining)
    |> Map.put(:instruction_pointer, instruction_pointer + 2)
    |> parse()
  end

  defp operation(
         4,
         %{registers: registers, output: output, instruction_pointer: instruction_pointer} =
           state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      }"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)

    # IO.puts("Output: #{param1}")

    Logger.debug("Output value: #{param1}")

    state
    |> Map.put(:output, [param1] ++ output)
    |> Map.put(:instruction_pointer, instruction_pointer + 2)
    |> parse()
  end

  defp operation(
         5,
         %{registers: registers, instruction_pointer: instruction_pointer} = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      },#{Map.get(registers, instruction_pointer + 2)}"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    param2 = get_param(state, instruction_pointer + 2, param_codes, 1)

    if param1 != 0 do
      Logger.debug("Adjusting pointer to #{param2}")

      state
      |> Map.put(:instruction_pointer, param2)
      |> parse()
    else
      Logger.debug("Move to next instruction set")

      state
      |> Map.put(:instruction_pointer, instruction_pointer + 3)
      |> parse()
    end
  end

  defp operation(
         6,
         %{registers: registers, instruction_pointer: instruction_pointer} = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      },#{Map.get(registers, instruction_pointer + 2)}"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    param2 = get_param(state, instruction_pointer + 2, param_codes, 1)

    if param1 == 0 do
      Logger.debug("Adjusting pointer to #{param2}")

      state
      |> Map.put(:instruction_pointer, param2)
      |> parse()
    else
      Logger.debug("Move to next instruction set")

      state
      |> Map.put(:instruction_pointer, instruction_pointer + 3)
      |> parse()
    end
  end

  defp operation(
         7,
         %{
           registers: registers,
           instruction_pointer: instruction_pointer
         } = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      },#{Map.get(registers, instruction_pointer + 2)},#{
        Map.get(registers, instruction_pointer + 3)
      }"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    param2 = get_param(state, instruction_pointer + 2, param_codes, 1)
    position = get_position_param(state, instruction_pointer + 3, param_codes, 2)

    Logger.debug("#{param1} < #{param2}?")

    if param1 < param2 do
      Logger.debug("Set state #{position} to 1")
      put_in(state[:registers][position], 1)
    else
      Logger.debug("Set state #{position} to 0")
      put_in(state[:registers][position], 0)
    end
    |> Map.put(:instruction_pointer, instruction_pointer + 4)
    |> parse()
  end

  defp operation(
         8,
         %{
           registers: registers,
           instruction_pointer: instruction_pointer
         } = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      },#{Map.get(registers, instruction_pointer + 2)},#{
        Map.get(registers, instruction_pointer + 3)
      }"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    param2 = get_param(state, instruction_pointer + 2, param_codes, 1)
    position = get_position_param(state, instruction_pointer + 3, param_codes, 2)
    Logger.debug("#{param1} == #{param2}?")

    if param1 == param2 do
      Logger.debug("Set state #{position} to 1")
      put_in(state[:registers][position], 1)
    else
      Logger.debug("Set state #{position} to 0")
      put_in(state[:registers][position], 0)
    end
    |> Map.put(:instruction_pointer, instruction_pointer + 4)
    |> parse()
  end

  defp operation(
         9,
         %{
           registers: registers,
           instruction_pointer: instruction_pointer,
           relative_base: relative_base
         } = state,
         param_codes
       ) do
    Logger.debug(
      "Instruction: #{Map.get(registers, instruction_pointer)},#{
        Map.get(registers, instruction_pointer + 1)
      }"
    )

    param1 = get_param(state, instruction_pointer + 1, param_codes, 0)
    new_relative_base = relative_base + param1
    Logger.debug("Adjusted relative base to #{new_relative_base}")

    Map.put(state, :relative_base, new_relative_base)
    |> Map.put(:instruction_pointer, instruction_pointer + 2)
    |> parse()
  end

  defp operation(99, state, _), do: {:halt, state}

  defp param_modes(_pms, 4), do: []

  defp param_modes(pms, count) do
    [rem(pms, 10)] ++ param_modes(div(pms, 10), count + 1)
  end

  def parse(%{registers: registers, instruction_pointer: instruction_pointer} = state) do
    Map.get(registers, instruction_pointer, 0)
    |> case do
      code when code in [1, 2, 3, 4, 99] ->
        code |> operation(state, [0, 0, 0])

      code ->
        opcode = rem(code, 100)
        pm = code |> div(100) |> param_modes(1)
        opcode |> operation(state, pm)
    end
  end

  def registers_to_new_state(registers) do
    %{
      registers: registers,
      input: [],
      output: [],
      instruction_pointer: 0,
      relative_base: 0
    }
  end

  def list_to_map(lst) do
    Enum.reduce(Enum.with_index(lst), %{}, fn {val, key}, acc ->
      Map.put(acc, key, val)
    end)
  end
end
