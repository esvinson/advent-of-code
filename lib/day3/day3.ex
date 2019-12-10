defmodule Advent.Day3 do
  @moduledoc """
  --- Day 3: Crossed Wires ---
  The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

  Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

  The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

  For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

  ...........
  ...........
  ...........
  ....+----+.
  ....|....|.
  ....|....|.
  ....|....|.
  .........|.
  .o-------+.
  ...........
  Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

  ...........
  .+-----+...
  .|.....|...
  .|..+--X-+.
  .|..|..|.|.
  .|.-X--+.|.
  .|..|....|.
  .|.......|.
  .o-------+.
  ...........
  These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

  Here are a few more examples:

  R75,D30,R83,U83,L12,D49,R71,U7,L72
  U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
  R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
  U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135
  What is the Manhattan distance from the central port to the closest intersection?
  """
  defp move_path(state, _x, _y, _step, _dir, 0), do: state

  defp move_path(state, x, y, step, :up, current) do
    new_y = y + 1
    key = {x, new_y}

    Map.put(state, key, {step + 1, 0})
    |> move_path(x, new_y, step + 1, :up, current - 1)
  end

  defp move_path(state, x, y, step, :down, current) do
    new_y = y - 1
    key = {x, new_y}

    Map.put(state, key, {step + 1, 0})
    |> move_path(x, new_y, step + 1, :down, current - 1)
  end

  defp move_path(state, x, y, step, :right, current) do
    new_x = x + 1
    key = {new_x, y}

    Map.put(state, key, {step + 1, 0})
    |> move_path(new_x, y, step + 1, :right, current - 1)
  end

  defp move_path(state, x, y, step, :left, current) do
    new_x = x - 1
    key = {new_x, y}

    Map.put(state, key, {step + 1, 0})
    |> move_path(new_x, y, step + 1, :left, current - 1)
  end

  defp path_intersections(_state, _x, _y, _step, _dir, 0, intersections), do: intersections

  defp path_intersections(state, x, y, step, :up, current, intersections) do
    new_y = y + 1
    key = {x, new_y}

    Map.get(state, key, {0, step + 1})
    |> case do
      {0, _y_step} ->
        state
        |> path_intersections(x, new_y, step + 1, :up, current - 1, intersections)

      {x_step, _y_step} ->
        state
        |> path_intersections(
          x,
          new_y,
          step + 1,
          :up,
          current - 1,
          intersections ++ [{key, {x_step, step + 1}}]
        )
    end
  end

  defp path_intersections(state, x, y, step, :down, current, intersections) do
    new_y = y - 1
    key = {x, new_y}

    Map.get(state, key, {0, step + 1})
    |> case do
      {0, _y_step} ->
        state
        |> path_intersections(x, new_y, step + 1, :down, current - 1, intersections)

      {x_step, _y_step} ->
        state
        |> path_intersections(
          x,
          new_y,
          step + 1,
          :down,
          current - 1,
          intersections ++ [{key, {x_step, step + 1}}]
        )
    end
  end

  defp path_intersections(state, x, y, step, :right, current, intersections) do
    new_x = x + 1
    key = {new_x, y}

    Map.get(state, key, {0, step + 1})
    |> case do
      {0, _y_step} ->
        state
        |> path_intersections(new_x, y, step + 1, :right, current - 1, intersections)

      {x_step, _y_step} ->
        state
        |> path_intersections(
          new_x,
          y,
          step + 1,
          :right,
          current - 1,
          intersections ++ [{key, {x_step, step + 1}}]
        )
    end
  end

  defp path_intersections(state, x, y, step, :left, current, intersections) do
    new_x = x - 1
    key = {new_x, y}

    Map.get(state, key, {0, step + 1})
    |> case do
      {0, _y_step} ->
        state
        |> path_intersections(new_x, y, step + 1, :left, current - 1, intersections)

      {x_step, _y_step} ->
        state
        |> path_intersections(
          new_x,
          y,
          step + 1,
          :left,
          current - 1,
          intersections ++ [{key, {x_step, step + 1}}]
        )
    end
  end

  defp traverse_path(state, _x, _y, _step, []), do: state

  defp traverse_path(state, x, y, step, [{dir, count} | path]) do
    new_state = move_path(state, x, y, step, dir, count)

    dir
    |> case do
      :up ->
        traverse_path(new_state, x, y + count, step + count, path)

      :down ->
        traverse_path(new_state, x, y - count, step + count, path)

      :right ->
        traverse_path(new_state, x + count, y, step + count, path)

      :left ->
        traverse_path(new_state, x - count, y, step + count, path)
    end
  end

  defp traverse_path_for_intersections(_state, _x, _y, _step, [], intersections),
    do: intersections

  defp traverse_path_for_intersections(state, x, y, step, [{dir, count} | path], intersections) do
    new_intersections = path_intersections(state, x, y, step, dir, count, intersections)

    dir
    |> case do
      :up ->
        traverse_path_for_intersections(
          state,
          x,
          y + count,
          step + count,
          path,
          new_intersections
        )

      :down ->
        traverse_path_for_intersections(
          state,
          x,
          y - count,
          step + count,
          path,
          new_intersections
        )

      :right ->
        traverse_path_for_intersections(
          state,
          x + count,
          y,
          step + count,
          path,
          new_intersections
        )

      :left ->
        traverse_path_for_intersections(
          state,
          x - count,
          y,
          step + count,
          path,
          new_intersections
        )
    end
  end

  defp build_map_from_path(path) do
    %{"0,0" => {0, 0}}
    |> traverse_path(0, 0, 0, path)
  end

  defp direction_and_distance(dir_count) do
    direction =
      dir_count
      |> String.slice(0, 1)
      |> case do
        "U" ->
          :up

        "D" ->
          :down

        "L" ->
          :left

        "R" ->
          :right
      end

    count =
      dir_count
      |> String.slice(1, String.length(dir_count))
      |> String.to_integer()

    {direction, count}
  end

  defp find_intersections(state, path2) do
    traverse_path_for_intersections(state, 0, 0, 0, path2, [])
  end

  defp parse_file do
    File.read!("lib/day3/day3.input")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn row ->
      String.split(row, ",")
      |> Enum.map(&direction_and_distance(&1))
    end)
  end

  def part1 do
    paths = parse_file()

    paths
    |> Enum.at(0)
    |> build_map_from_path()
    |> find_intersections(Enum.at(paths, 1))
    |> Enum.map(fn {{x, y}, _steps} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  def part2 do
    paths = parse_file()

    paths
    |> Enum.at(0)
    |> build_map_from_path()
    |> find_intersections(Enum.at(paths, 1))
    |> Enum.map(fn {_coords, {step_1, step_2}} -> step_1 + step_2 end)
    |> Enum.min()
  end

  def test do
    :ok
  end
end
