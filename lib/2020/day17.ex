defmodule Aoc202017 do
  def test_input,
    do: """
    .#.
    ..#
    ###
    """

  def translate("#"), do: :active
  def translate("."), do: :inactive

  def input_to_map(input, dimensions) when dimensions in [3, 4] do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {xes, y}, acc ->
      xes
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {val, x}, subacc ->
        Map.put(subacc, if(dimensions == 4, do: {x, y, 0, 0}, else: {x, y, 0}), translate(val))
      end)
    end)
  end

  defp drop_inactive(state) do
    Enum.reduce(state, %{}, fn {key, val}, acc ->
      val
      |> case do
        :inactive -> acc
        _ -> Map.put(acc, key, val)
      end
    end)
  end

  defp handle_offsets({x, y, z}, {setx, sety, setz}), do: {x + setx, y + sety, z + setz}

  defp handle_offsets({x, y, z, w}, {setx, sety, setz, setw}),
    do: {x + setx, y + sety, z + setz, w + setw}

  defp handle_move(state, coords, set_coords, acc) do
    Map.get(state, handle_offsets(coords, set_coords), :inactive)
    |> case do
      :inactive -> acc
      :active -> acc + 1
    end
  end

  defp count_active_neighbors(state, sets, key) do
    Enum.reduce(sets, 0, fn offsets, acc -> handle_move(state, key, offsets, acc) end)
  end

  defp transition(state, _sets, 0), do: state

  defp transition(state, sets, count) do
    state
    |> Map.keys()
    |> Enum.reduce(MapSet.new(), fn coords, acc ->
      Enum.reduce(sets, acc, fn set_coords, subacc ->
        MapSet.put(subacc, handle_offsets(coords, set_coords))
      end)
      |> MapSet.put(coords)
    end)
    |> Enum.reduce(state, fn coords, acc ->
      neighbor_count = count_active_neighbors(state, sets, coords)

      state
      |> Map.get(coords, :inactive)
      |> case do
        :inactive ->
          if neighbor_count == 3,
            do: Map.put(acc, coords, :active),
            else: Map.delete(acc, coords)

        :active ->
          if neighbor_count in [2, 3],
            do: acc,
            else: Map.delete(acc, coords)
      end
    end)
    |> transition(sets, count - 1)
  end

  def build_sets(dimensions) when dimensions in [3, 4] do
    Enum.reduce(-1..1, [], fn x, acc ->
      Enum.reduce(-1..1, acc, fn y, yacc ->
        Enum.reduce(-1..1, yacc, fn z, zacc ->
          if dimensions == 4 do
            Enum.reduce(-1..1, zacc, fn w, wacc ->
              if x == 0 && y == 0 && z == 0 && w == 0, do: wacc, else: [{x, y, z, w} | wacc]
            end)
          else
            if x == 0 && y == 0 && z == 0, do: zacc, else: [{x, y, z} | zacc]
          end
        end)
      end)
    end)
  end

  def do_work(current_state, sets) do
    current_state
    |> transition(sets, 6)
    |> Enum.filter(fn {_index, val} -> val == :active end)
    |> Enum.count()
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_map(3)
      |> drop_inactive()

    sets_3 = build_sets(3)
    IO.puts(Enum.count(sets_3))

    input =
      Advent.daily_input("2020", "17")
      |> input_to_map(3)
      |> drop_inactive()

    test_result1 = do_work(test_input1, sets_3)
    IO.puts("Solution to Test Part 1 (Should be 112): #{test_result1}")

    result1 = do_work(input, sets_3)
    IO.puts("Solution to Part 1: #{result1}")

    test_input2 =
      test_input()
      |> input_to_map(4)
      |> drop_inactive()

    input2 =
      Advent.daily_input("2020", "17")
      |> input_to_map(4)
      |> drop_inactive()

    sets_4 = build_sets(4)

    test_result2 = do_work(test_input2, sets_4)
    IO.puts("Solution to Test Part 2 (Should be 848): #{test_result2}")

    result2 = do_work(input2, sets_4)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
