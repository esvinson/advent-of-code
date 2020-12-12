defmodule Aoc202012pt2 do
  def test_input,
    do: """
    F10
    N3
    F7
    R90
    F11
    """

  defp translate("N"), do: :north
  defp translate("S"), do: :south
  defp translate("E"), do: :east
  defp translate("W"), do: :west
  defp translate("F"), do: :forward
  defp translate("R"), do: :right
  defp translate("L"), do: :left

  def input_to_list(input) do
    input
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [direction, distance] = String.split(row, "", parts: 2, trim: true)
      %{direction: translate(direction), distance: String.to_integer(distance)}
    end)
  end

  defp rotate(:right, x, y, 90), do: {y, x * -1}
  defp rotate(:right, x, y, 180), do: {x * -1, y * -1}
  defp rotate(:right, x, y, 270), do: {y * -1, x}

  defp rotate(:left, x, y, 90), do: {y * -1, x}
  defp rotate(:left, x, y, 180), do: {x * -1, y * -1}
  defp rotate(:left, x, y, 270), do: {y, x * -1}

  # :right 0 = 10, 1
  # :right 90 = 1, -10
  # :right 180 = -10, -1
  # :right 270 = -1, 10
  # :left 0 = 10, 1
  # :left 90 = -1, 10 == :right 270
  # :left 180 = -10, -1 == :right 180
  # :left 270 = 1, -10 == :right 90

  defp rotate_waypoint(direction, distance, {ship_x, ship_y, waypoint_x, waypoint_y}) do
    {new_x_offset, new_y_offset} =
      rotate(direction, waypoint_x - ship_x, waypoint_y - ship_y, distance)

    {ship_x, ship_y, ship_x + new_x_offset, ship_y + new_y_offset}
  end

  defp do_move(ship_x, ship_y, waypoint_x, waypoint_y, :north, distance),
    do: {ship_x, ship_y, waypoint_x, waypoint_y + distance}

  defp do_move(ship_x, ship_y, waypoint_x, waypoint_y, :east, distance),
    do: {ship_x, ship_y, waypoint_x + distance, waypoint_y}

  defp do_move(ship_x, ship_y, waypoint_x, waypoint_y, :south, distance),
    do: {ship_x, ship_y, waypoint_x, waypoint_y - distance}

  defp do_move(ship_x, ship_y, waypoint_x, waypoint_y, :west, distance),
    do: {ship_x, ship_y, waypoint_x - distance, waypoint_y}

  defp move_waypoint({ship_x, ship_y, waypoint_x, waypoint_y}, %{
         direction: direction,
         distance: distance
       })
       when direction in [:north, :east, :south, :west],
       do: do_move(ship_x, ship_y, waypoint_x, waypoint_y, direction, distance)

  defp move_waypoint({ship_x, ship_y, waypoint_x, waypoint_y}, %{
         direction: direction,
         distance: distance
       })
       when direction in [:left, :right],
       do: rotate_waypoint(direction, distance, {ship_x, ship_y, waypoint_x, waypoint_y})

  defp move_ship({ship_x, ship_y, waypoint_x, waypoint_y}, %{
         direction: :forward,
         distance: distance
       }) do
    offset_x = waypoint_x - ship_x
    offset_y = waypoint_y - ship_y
    new_ship_x = ship_x + offset_x * distance
    new_ship_y = ship_y + offset_y * distance
    new_waypoint_x = waypoint_x + offset_x * distance
    new_waypoint_y = waypoint_y + offset_y * distance
    {new_ship_x, new_ship_y, new_waypoint_x, new_waypoint_y}
  end

  def part2(list) do
    {x, y, _, _} =
      list
      |> Enum.reduce({0, 0, 10, 1}, fn movement, acc ->
        movement
        |> case do
          %{direction: :forward} = movement ->
            move_ship(acc, movement)

          movement ->
            move_waypoint(acc, movement)
        end
      end)

    abs(x) + abs(y)
  end

  def run do
    test_input1 =
      test_input()
      |> input_to_list()

    input =
      Advent.daily_input("2020", "12")
      |> input_to_list()

    test_result2 = part2(test_input1)
    IO.puts("Solution to Test Part 2 (Should be 286): #{test_result2}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
