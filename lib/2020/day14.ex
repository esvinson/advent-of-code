defmodule Aoc202014 do
  def test_input,
    do: """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    """

  def transform(["mask", mask]), do: {:mask, mask}

  def transform([mem, value]) do
    offset = String.replace(mem, ~r/[^\d]/, "")

    val =
      value
      |> String.to_integer()
      |> Integer.to_string(2)
      |> String.pad_leading(36, "0")

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
        String.codepoints(val),
        String.codepoints(mask)
      )
      |> List.to_string()

    {mask, Map.put(state, offset, String.to_integer(new_val, 2))}
  end

  def part1(list) do
    list
    |> Enum.reduce({nil, %{}}, &handle_row/2)
    |> elem(1)
    |> Enum.reduce(0, fn {_key, x}, acc -> acc + x end)
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_list()

    input =
      Advent.daily_input("2020", "14")
      |> input_to_list()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 165): #{inspect(test_result1)}")

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")
  end
end
