defmodule Aoc202406 do
  defp parse(input) do
    [first | _rest] =
      start =
      input
      |> String.split("\n", trim: true)

    max_y = Enum.count(start)
    max_x = String.length(first)

    map =
      start
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc1 ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc1, fn {val, x}, acc2 ->
          if val == "^" do
            Map.put(acc2, {x, y}, val)
            |> Map.put(:start, {x, y})
          else
            Map.put(acc2, {x, y}, val)
          end
        end)
      end)

    %{map: map, height: max_y, width: max_x}
  end

  defp is_wall?(map, pos) do
    if Map.get(map, pos) == "#", do: true, else: false
  end

  defp turn(:north), do: :east
  defp turn(:east), do: :south
  defp turn(:south), do: :west
  defp turn(:west), do: :north

  defp next_position({x, y}, :north), do: {x, y - 1}
  defp next_position({x, y}, :east), do: {x + 1, y}
  defp next_position({x, y}, :south), do: {x, y + 1}
  defp next_position({x, y}, :west), do: {x - 1, y}

  defp traverse(_map, {x, y}, _direction, width, height, visited)
       when x < 0 or y < 0 or x == width or y == height,
       do: visited

  defp traverse(map, pos, direction, width, height, visited) do
    next = next_position(pos, direction)

    if is_wall?(map, next) do
      traverse(map, pos, turn(direction), width, height, visited)
    else
      traverse(map, next, direction, width, height, MapSet.put(visited, pos))
    end
  end

  defp part1(%{map: map, width: width, height: height}) do
    start = Map.get(map, :start)

    traverse(map, start, :north, width, height, MapSet.new([]))
    |> MapSet.size()
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      ....#.....
      .........#
      ..........
      ..#.......
      .......#..
      ..........
      .#..^.....
      ........#.
      #.........
      ......#...
      """
      |> parse()

    input =
      Advent.daily_input("2024", "06")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
