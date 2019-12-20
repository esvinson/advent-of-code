defmodule Advent.Opcodes do
  require Logger

  defp get_param(
         %{registers: registers} = state,
         instruction_pointer,
         params,
         offset
       ) do
    Enum.at(params, offset)
    |> case do
      2 ->
        Map.get(registers, get_position_param(state, instruction_pointer, params, offset), 0)

      1 ->
        get_position_param(state, instruction_pointer, params, offset)

      0 ->
        Map.get(registers, get_position_param(state, instruction_pointer, params, offset), 0)
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
        Map.get(registers, instruction_pointer, 0)

      0 ->
        Map.get(registers, instruction_pointer, 0)
    end
  end

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

  @doc """
  # Examples

  iex> Enum.map(
  ...> [1, 2, 3, 4, 99, 101, 102, 104, 108, 1001, 1002, 1005, 1006, 1007, 1008, 1106],
  ...> &Advent.Opcodes.param_modes(&1, 0)
  ...> )
  [
    {1, [0,0,0]},
    {2, [0,0,0]},
    {3, [0,0,0]},
    {4, [0,0,0]},
    {99, [0,0,0]},
    {1, [1,0,0]},
    {2, [1,0,0]},
    {4, [1,0,0]},
    {8, [1,0,0]},
    {1, [0,1,0]},
    {2, [0,1,0]},
    {5, [0,1,0]},
    {6, [0,1,0]},
    {7, [0,1,0]},
    {8, [0,1,0]},
    {6, [1,1,0]}
  ]

  """
  def param_modes(_pms, 4), do: []

  def param_modes(code, 0) do
    opcode = rem(code, 100)
    {opcode, param_modes(div(code, 100), 1)}
  end

  def param_modes(pms, count) do
    [rem(pms, 10)] ++ param_modes(div(pms, 10), count + 1)
  end

  @doc """
  # Examples

  iex> Advent.Opcodes.list_to_map([1,0,0,0,99])
  ...> |> Advent.Opcodes.registers_to_new_state()
  ...> |> Advent.Opcodes.parse() |> elem(1) |> Map.get(:registers)
  %{0 => 2, 1 => 0, 2 => 0, 3 => 0, 4 => 99}

  iex> Advent.Opcodes.list_to_map([1101,0,0,0,99])
  ...> |> Advent.Opcodes.registers_to_new_state()
  ...> |> Advent.Opcodes.parse() |> elem(1) |> Map.get(:registers)
  %{0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 99}

  iex> Advent.Opcodes.list_to_map([2,3,0,3,99])
  ...> |> Advent.Opcodes.registers_to_new_state()
  ...> |> Advent.Opcodes.parse() |> elem(1) |> Map.get(:registers)
  %{0 => 2, 1 => 3, 2 => 0, 3 => 6, 4 => 99}

  iex> Advent.Opcodes.list_to_map([2,4,4,5,99,0])
  ...> |> Advent.Opcodes.registers_to_new_state()
  ...> |> Advent.Opcodes.parse() |> elem(1) |> Map.get(:registers)
  %{0 => 2, 1 => 4, 2 => 4, 3 => 5, 4 => 99, 5 => 9801}

  iex> Advent.Opcodes.list_to_map([1,1,1,4,99,5,6,0,99])
  ...> |> Advent.Opcodes.registers_to_new_state()
  ...> |> Advent.Opcodes.parse() |> elem(1) |> Map.get(:registers)
  %{0 => 30, 1 => 1, 2 => 1, 3 => 4, 4 => 2, 5 => 5, 6 => 6, 7 => 0, 8 => 99}

  """

  def parse(%{registers: registers, instruction_pointer: instruction_pointer} = state) do
    Map.get(registers, instruction_pointer, 0)
    |> case do
      code when code in [1, 2, 3, 4, 99] ->
        code |> operation(state, [0, 0, 0])

      code ->
        {opcode, pm} = param_modes(code, 0)
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

  @doc """
  # Examples

  iex> Advent.Opcodes.list_to_map([1,0,0,0,99])
  %{0 => 1, 1 => 0, 2 => 0, 3 => 0, 4 => 99}
  """
  def list_to_map(lst) do
    Enum.reduce(Enum.with_index(lst), %{}, fn {val, key}, acc ->
      Map.put(acc, key, val)
    end)
  end

  def map_to_list(map) do
    Map.keys(map)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.reduce([], fn x, acc ->
      [Map.get(map, x)] ++ acc
    end)
  end

  @doc """
  # Examples

  iex> Advent.Opcodes.test_code("1,0,3,5,99")
  [1, 0, 3, 5, 99, 6]

  iex> Advent.Opcodes.test_code("101,30,4,5,99")
  [101, 30, 4, 5, 99, 129]

  iex> Advent.Opcodes.test_code("1001,0,15,5,99")
  [1001, 0, 15, 5, 99, 1016]

  iex> Advent.Opcodes.test_code("1101,18,32,5,99")
  [1101, 18, 32, 5, 99, 50]

  iex> Advent.Opcodes.test_code("2,0,3,5,99")
  [2, 0, 3, 5, 99, 10]

  iex> Advent.Opcodes.test_code("102,30,4,5,99")
  [102, 30, 4, 5, 99, 2970]

  iex> Advent.Opcodes.test_code("1002,0,15,5,99")
  [1002, 0, 15, 5, 99, 15030]

  iex> Advent.Opcodes.test_code("1102,18,32,5,99")
  [1102, 18, 32, 5, 99, 576]

  iex> Advent.Opcodes.test_code("3,3,99", [5])
  [3, 3, 99, 5]

  iex> Advent.Opcodes.test_code("103,3,99", [5])
  [103, 3, 99, 5]

  iex> Advent.Opcodes.test_code("203,-2", [99], 4)
  [203, -2, 99]

  iex> Advent.Opcodes.test_output("4,2,99")
  [99]

  iex> Advent.Opcodes.test_output("104,2,99")
  [2]

  iex> Advent.Opcodes.test_output("204,0,99", [], 2)
  [99]

  iex> Advent.Opcodes.test_code("5,0,3,6,2,3,99")
  [5,0,3,6,2,3,99]

  iex> Advent.Opcodes.test_code("105,85,3,6,2,3,99")
  [105,85,3,6,2,3,99]

  iex> Advent.Opcodes.test_code("1105,85,6,1,2,3,99")
  [1105,85,6,1,2,3,99]

  iex> Advent.Opcodes.test_code("1205,0,6,99", [], 5)
  [1205,0,6,99]

  iex> Advent.Opcodes.test_code("1205,0,6,1,2,3,99", [], 5)
  [1205,0,6,1,2,3,99]

  iex> Advent.Opcodes.test_code("2205,1,2,3,1,6,99", [], 3)
  [2205,1,2,3,1,6,99]

  # privided examples day 5
  iex> Advent.Opcodes.test_output("3,9,8,9,10,9,4,9,99,-1,8", [8])
  [1]

  iex> Advent.Opcodes.test_output("3,9,8,9,10,9,4,9,99,-1,8", [7])
  [0]

  iex> Advent.Opcodes.test_output("3,9,7,9,10,9,4,9,99,-1,8", [6])
  [1]

  iex> Advent.Opcodes.test_output("3,9,7,9,10,9,4,9,99,-1,8", [8])
  [0]

  iex> Advent.Opcodes.test_output("3,3,1108,-1,8,3,4,3,99", [8])
  [1]

  iex> Advent.Opcodes.test_output("3,3,1108,-1,8,3,4,3,99", [7])
  [0]

  iex> Advent.Opcodes.test_output("3,3,1107,-1,8,3,4,3,99", [6])
  [1]

  iex> Advent.Opcodes.test_output("3,3,1107,-1,8,3,4,3,99", [8])
  [0]

  iex> Advent.Opcodes.test_output("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", [9])
  [1]

  iex> Advent.Opcodes.test_output("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", [0])
  [0]

  iex> Advent.Opcodes.test_output("3,3,1105,-1,9,1101,0,0,12,4,12,99,1", [9])
  [1]

  iex> Advent.Opcodes.test_output("3,3,1105,-1,9,1101,0,0,12,4,12,99,1", [0])
  [0]

  iex> Advent.Opcodes.test_output("3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99", [2])
  [999]

  iex> Advent.Opcodes.test_output("3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99", [8])
  [1000]

  iex> Advent.Opcodes.test_output("3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99", [100])
  [1001]



  """

  def test_code(instruction, input \\ [], relative_base \\ 0) do
    {:halt, result} =
      instruction
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> list_to_map()
      |> registers_to_new_state()
      |> Map.put(:input, input)
      |> Map.put(:relative_base, relative_base)
      |> parse()

    result
    |> Map.get(:registers)
    |> map_to_list()
  end

  def test_output(instruction, input \\ [], relative_base \\ 0) do
    {:halt, result} =
      instruction
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> list_to_map()
      |> registers_to_new_state()
      |> Map.put(:input, input)
      |> Map.put(:relative_base, relative_base)
      |> parse()

    result
    |> Map.get(:output)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
