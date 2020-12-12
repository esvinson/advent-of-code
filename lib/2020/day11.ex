defmodule Aoc202011 do
  def test_input,
    do: """
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """

  def translate("L"), do: :empty
  def translate("#"), do: :occupied
  def translate("."), do: :floor

  def input_to_map(input) do
    rows =
      input
      |> to_string()
      |> String.split("\n", trim: true)

    row_count = Enum.count(rows)

    column_count =
      rows
      |> List.first()
      |> String.split("", trim: true)
      |> Enum.count()

    map =
      rows
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {xes, y}, acc ->
        xes
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {val, x}, subacc ->
          Map.put(subacc, {x, y}, translate(val))
        end)
      end)

    %{rows: row_count, cols: column_count, map: map}
  end

  defp drop_floor(state) do
    Enum.reduce(state, %{}, fn {key, val}, acc ->
      val
      |> case do
        :floor -> acc
        _ -> Map.put(acc, key, val)
      end
    end)
  end

  defp deeper(_state, acc, x, _y, setx, _sety, depth) when x + setx * depth < 0, do: acc
  defp deeper(_state, acc, _x, y, _setx, sety, depth) when y + sety * depth < 0, do: acc

  defp deeper(state, acc, x, y, setx, sety, depth) do
    new_x = x + setx * depth
    new_y = y + sety * depth

    cond do
      new_x > state.cols ->
        acc

      new_y > state.rows ->
        acc

      true ->
        state.map
        |> Map.get({new_x, new_y}, :floor)
        |> case do
          :floor -> deeper(state, acc, x, y, setx, sety, depth + 1)
          :empty -> acc
          :occupied -> acc + 1
        end
    end
  end

  @sets [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, 1},
    {1, 0},
    {1, -1}
  ]

  defp count_occupied_neighbors(state, x, y, part2?) do
    Enum.reduce(@sets, 0, fn {setx, sety}, acc ->
      Map.get(state.map, {x + setx, y + sety}, :floor)
      |> case do
        :floor -> if part2?, do: deeper(state, acc, x, y, setx, sety, 2), else: acc
        :empty -> acc
        :occupied -> acc + 1
      end
    end)
  end

  defp transition(state, part2? \\ false) do
    keys = Map.keys(state.map)

    accceptable_neighbors = if part2?, do: 5, else: 4

    new_state_map =
      Enum.reduce(keys, state.map, fn {x, y}, acc ->
        neighbor_count = count_occupied_neighbors(state, x, y, part2?)

        state.map
        |> Map.get({x, y}, :floor)
        |> case do
          :floor ->
            acc

          :empty ->
            if neighbor_count == 0, do: Map.put(acc, {x, y}, :occupied), else: acc

          :occupied ->
            if neighbor_count >= accceptable_neighbors,
              do: Map.put(acc, {x, y}, :empty),
              else: acc
        end
      end)

    new_state = Map.put(state, :map, new_state_map)

    if Map.equal?(new_state.map, state.map) do
      new_state.map
      |> Enum.filter(fn {_index, val} -> val == :occupied end)
      |> Enum.count()
    else
      transition(new_state, part2?)
    end
  end

  def part1(current_state) do
    current_state
    |> transition()
  end

  def part2(current_state) do
    current_state
    |> transition(true)
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_map()
      |> drop_floor()

    input =
      Advent.daily_input("2020", "11")
      |> input_to_map()
      |> drop_floor()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 37): #{test_result1}")

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    test_result2 = part2(test_input1)
    IO.puts("Solution to Test Part 2 (Should be 26): #{test_result2}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
