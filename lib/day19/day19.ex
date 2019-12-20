defmodule Advent.Day19 do
  alias Advent.Opcodes

  def char(0), do: " "
  def char(1), do: "#"

  def draw(output) do
    {graph, count} =
      Enum.reduce(0..49, {"", 0}, fn y, {str, counter} ->
        {ystr, ycount} =
          Enum.reduce(0..49, {"", 0}, fn x, {str2, counter2} ->
            result = Map.get(output, {x, y})

            result
            |> case do
              1 ->
                {str2 <> char(result), counter2 + 1}

              0 ->
                {str2 <> char(result), counter2}
            end
          end)

        {str <> ystr <> "\n", counter + ycount}
      end)

    IO.puts(graph)
    IO.puts(count)
  end

  def part1 do
    initial_state =
      Advent.daily_input(19)
      |> Opcodes.parse_input()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()

    Enum.reduce(0..49, %{}, fn y, acc ->
      Enum.reduce(0..49, %{}, fn x, acc2 ->
        output =
          initial_state
          |> Map.put(:input, [x, y])
          |> Opcodes.parse()
          |> elem(1)
          |> Map.get(:output)
          |> hd()

        Map.put(acc2, {x, y}, output)
      end)
      |> Map.merge(acc)
    end)
    |> draw()
  end

  defp first_one_for_row(initial_state, {x, y}) do
    get_for_xy({x, y}, initial_state)
    |> case do
      1 ->
        {x, y}

      0 ->
        first_one_for_row(initial_state, {x + 1, y})
    end
  end

  defp get_for_xy({x, y}, initial_state) do
    initial_state
    |> Map.put(:input, [x, y])
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
    |> hd()
  end

  defp get_comparison_xy({x, y}), do: {x + 99, y - 99}
  defp adjust_for_output({{x, y}, _}), do: {x, y - 99}
  defp calculate_answer({x, y}), do: x * 10000 + y

  def part2 do
    initial_state =
      Advent.daily_input(19)
      |> Opcodes.parse_input()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()

    {first_one_for_row(initial_state, {0, 100}), 0}
    |> Stream.iterate(fn {{x, y}, _val} ->
      new_xy = first_one_for_row(initial_state, {x, y + 1})

      new_val =
        new_xy
        |> get_comparison_xy()
        |> get_for_xy(initial_state)

      {new_xy, new_val}
    end)
    |> Stream.drop_while(fn {_pos, val} -> val != 1 end)
    |> Enum.take(1)
    |> Enum.at(0)
    |> adjust_for_output()
    |> calculate_answer()
  end
end
