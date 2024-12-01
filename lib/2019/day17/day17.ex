defmodule Advent.Day17 do
  alias Advent.Opcodes

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def output_to_map(graph) do
    graph
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {row, index}, {acc, _x, _y} ->
      row_map =
        row
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {chr, index2}, acc2 ->
          Map.put(acc2, {index2, index}, chr)
        end)

      {Map.merge(acc, row_map), Enum.count(row), index}
    end)
  end

  def calculate(intersections) do
    intersections
    |> Enum.map(fn {x, y} ->
      x * y
    end)
    |> Enum.sum()
  end

  def test1 do
    {map, max_x, max_y} =
      """
      ..#..........
      ..#..........
      #######...###
      #.#...#...#.#
      #############
      ..#...#...#..
      ..#####...^..
      """
      |> output_to_map()

    find_intersections(map, max_x, max_y)
    |> calculate()
    |> inspect()
    |> IO.puts()

    :ok
  end

  def find_intersections(map, max_x, max_y) do
    Enum.reduce(0..(max_y - 1), [], fn y, acc ->
      Enum.reduce(0..(max_x - 1), [], fn x, acc2 ->
        if Map.get(map, {x, y}, ".") == "#" &&
             Map.get(map, {x - 1, y}, ".") == "#" &&
             Map.get(map, {x + 1, y}, ".") == "#" &&
             Map.get(map, {x, y + 1}, ".") == "#" &&
             Map.get(map, {x, y - 1}, ".") == "#" do
          [{x, y}] ++ acc2
        else
          acc2
        end
      end)
      |> Kernel.++(acc)
    end)
  end

  def draw(map) do
    IO.puts(map)
    map
  end

  def part1 do
    {_state, result} =
      Advent.daily_input(17)
      |> parse_input()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()
      |> Opcodes.parse()

    {map, max_x, max_y} =
      result
      |> Map.get(:output)
      |> Enum.reverse()
      |> draw()
      |> output_to_map()

    find_intersections(map, max_x, max_y)
    |> calculate()
    |> inspect()
    |> IO.puts()

    :ok
  end

  @spec make_list(charlist) :: [any]
  def make_list([]), do: []
  def make_list([hd | rest]), do: [hd] ++ make_list(rest)

  def part2 do
    # I did this part manually :shrug:
    # L,6,R,8,R,12,L,6,L,8,L,10,L,8,R,12,L,6,R,8,R,12,L,6,L,8,L,8,L,10,L,6,L,6,L,10,L,8,R,12,L,8,L,10,L,6,L,6,L,10,L,8,R,12,L,6,R,8,R,12,L,6,L,8,L,8,L,10,L,6,L,6,L,10,L,8,R,12
    # A,B,A,C,B,C,B,A,C,B
    # A=L,6,R,8,R,12,L,6,L,8
    # B=L,10,L,8,R,12
    # C=L,8,L,10,L,6,L,6
    input =
      make_list(
        ~c"A,B,A,C,B,C,B,A,C,B\nL,6,R,8,R,12,L,6,L,8\nL,10,L,8,R,12\nL,8,L,10,L,6,L,6\nN\n"
      )

    Advent.daily_input(17)
    |> parse_input()
    |> Opcodes.list_to_map()
    |> Map.put(0, 2)
    |> Opcodes.registers_to_new_state()
    |> Map.put(:input, input)
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
    |> Enum.reverse()
    |> draw()
    |> Enum.reverse()
    |> hd()
  end
end
