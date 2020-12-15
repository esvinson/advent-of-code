defmodule Aoc202014 do
  def test_input,
    do: """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """

  def test_input_pt2,
    do: """
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
    """

  def to_binary_36(value) do
    value
    |> Integer.to_string(2)
    |> String.pad_leading(36, "0")
  end

  @spec transform([...]) :: {:mask, any} | {:mem, binary, integer}
  def transform(["mask", mask]), do: {:mask, mask}

  def transform([mem, value]) do
    offset = String.replace(mem, ~r/[^\d]/, "") |> String.to_integer()

    val =
      value
      |> String.to_integer()

    {:mem, offset, val}
  end

  def input_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> row |> String.split(" = ", trim: true) |> transform() end)
  end

  def apply_mask([], []), do: []

  def apply_mask([val | rest], ["X" | mask_rest]), do: [val | apply_mask(rest, mask_rest)]

  def apply_mask([_val | rest], [mask_val | mask_rest]),
    do: [mask_val | apply_mask(rest, mask_rest)]

  def handle_row({:mask, mask}, {_current_mask, state}), do: {mask, state}

  def handle_row({:mem, offset, val}, {mask, state}) do
    new_val =
      apply_mask(
        String.codepoints(to_binary_36(val)),
        String.codepoints(mask)
      )
      |> List.to_string()

    {mask, Map.put(state, offset, String.to_integer(new_val, 2))}
  end

  def apply_mask_v2([], []), do: [""]

  def apply_mask_v2([val | rest], ["0" | mask_rest]),
    do: Enum.map(apply_mask_v2(rest, mask_rest), fn row -> val <> row end)

  def apply_mask_v2([_val | rest], ["1" | mask_rest]),
    do: Enum.map(apply_mask_v2(rest, mask_rest), fn row -> "1" <> row end)

  def apply_mask_v2([_val | rest], ["X" | mask_rest]) do
    apply_mask_v2(rest, mask_rest)
    |> Enum.flat_map(fn val ->
      ["0" <> val, "1" <> val]
    end)
  end

  def handle_row_v2({:mask, mask}, {_current_mask, current_state}), do: {mask, current_state}

  def handle_row_v2({:mem, offset, val}, {mask, current_state}) do
    new_state =
      apply_mask_v2(
        String.codepoints(to_binary_36(offset)),
        String.codepoints(mask)
      )
      |> Enum.reduce(current_state, fn offset_binary, state ->
        new_offset = String.to_integer(offset_binary, 2)
        Map.put(state, new_offset, val)
      end)

    {mask, new_state}
  end

  def part1(list) do
    list
    |> Enum.reduce({nil, %{}}, &handle_row/2)
    |> elem(1)
    |> Enum.reduce(0, fn {_key, x}, acc -> acc + x end)
  end

  def part2(list) do
    list
    |> Enum.reduce({nil, %{}}, &handle_row_v2/2)
    |> elem(1)
    |> Enum.reduce(0, fn {_key, x}, acc -> acc + x end)
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_list()

    test_input2 =
      test_input_pt2()
      |> input_to_list()

    input =
      Advent.daily_input("2020", "14")
      |> input_to_list()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 165): #{inspect(test_result1)}")

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2 = part2(test_input2)
    IO.puts("Solution to Test Part 2 (Should be 208): #{inspect(test_result2)}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
