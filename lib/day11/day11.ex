defmodule Advent.Day11 do
  alias Advent.Opcodes

  defp parse_file do
    Advent.daily_input(11)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp direction_after_turn(:up, 0), do: :left
  defp direction_after_turn(:up, 1), do: :right
  defp direction_after_turn(:left, 0), do: :down
  defp direction_after_turn(:left, 1), do: :up
  defp direction_after_turn(:down, 0), do: :right
  defp direction_after_turn(:down, 1), do: :left
  defp direction_after_turn(:right, 0), do: :up
  defp direction_after_turn(:right, 1), do: :down

  defp move(x, y, :up), do: {x, y - 1}
  defp move(x, y, :down), do: {x, y + 1}
  defp move(x, y, :left), do: {x - 1, y}
  defp move(x, y, :right), do: {x + 1, y}

  @doc """
  # Example

  iex> Advent.Day11.paint_surface(%{x: 0, y: 0, direction: :up, grid: %{}}, [1, 0])
  %{direction: :left, grid: %{0 => %{0 => 1}}, x: -1, y: 0}

  iex> Advent.Day11.paint_surface(%{x: -1, y: 0, direction: :left, grid: %{0 => %{0 => 1}}}, [0, 0])
  %{direction: :down, grid: %{0 => %{0 => 1, -1 => 0}}, x: -1, y: 1}

  iex> Advent.Day11.paint_surface(%{x: 0, y: 0, direction: :up, grid: %{}}, [1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0])
  ...> |> Map.get(:grid)
  ...> |> Advent.Day11.painted_tiles()
  6

  iex> Advent.Day11.paint_surface(%{x: 0, y: 0, direction: :up, grid: %{}}, [1, 1, 1, 1, 1, 1, 1, 1])
  %{
    direction: :up,
    grid: %{1 => %{0 => 1, 1 => 1}, 0 => %{0 => 1, 1 => 1}},
    x: 0,
    y: 0
  }

  iex> Advent.Day11.paint_surface(%{x: 0, y: 0, direction: :up, grid: %{}}, [1, 1, 1, 1, 1, 1, 1, 1])
  ...> |> Map.get(:grid)
  ...> |> Advent.Day11.painted_tiles()
  4

  iex> Advent.Day11.paint_surface(%{x: 0, y: 0, direction: :up, grid: %{}}, [1, 0, 1, 0, 1, 0, 1, 0])
  %{
    direction: :up,
    grid: %{1 => %{0 => 1, -1 => 1}, 0 => %{0 => 1, -1 => 1}},
    x: 0,
    y: 0
  }
  """
  def paint_surface(surface, []), do: surface

  def paint_surface(%{x: x, y: y, direction: direction, grid: grid}, [color, turn | remaining]) do
    row = Map.get(grid, y, %{})
    new_row = Map.put(row, x, color)
    new_grid = Map.put(grid, y, new_row)
    new_direction = direction_after_turn(direction, turn)
    {new_x, new_y} = move(x, y, new_direction)
    paint_surface(%{x: new_x, y: new_y, direction: new_direction, grid: new_grid}, remaining)
  end

  def do_work(
        prev_state,
        %{x: x, y: y, grid: grid} = surface
      ) do
    current_color =
      grid
      |> Map.get(y, %{})
      |> Map.get(x, 0)

    {status, %{output: [turn, color]} = state} =
      prev_state
      |> Map.put(:input, [current_color])
      |> Opcodes.parse()

    new_state = Map.put(state, :output, [])

    new_surface = paint_surface(surface, [color, turn])

    if status == :halt do
      new_surface
    else
      new_state
      |> do_work(new_surface)
    end
  end

  def painted_tiles(result) do
    result
    |> Map.keys()
    |> Enum.reduce(0, fn key, total ->
      result
      |> Map.get(key, %{})
      |> Map.keys()
      |> Enum.count()
      |> Kernel.+(total)
    end)
  end

  def part1 do
    %{grid: result} =
      parse_file()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()
      |> do_work(%{x: 0, y: 0, direction: :up, grid: %{}})

    result
    |> painted_tiles()
  end

  def char(1), do: "#"
  def char(0), do: " "

  def render(grid) do
    max_y = grid |> Map.keys() |> Enum.max()
    min_y = grid |> Map.keys() |> Enum.min()
    {min_y, max_y}

    {min_x, max_x} =
      Enum.map(grid, fn {_key, row} ->
        max_x =
          row
          |> Map.keys()
          |> Enum.max()

        min_x =
          row
          |> Map.keys()
          |> Enum.min()

        {min_x, max_x}
      end)
      |> Enum.reduce({:infinity, -999_999}, fn {min_x, max_x}, {prev_min_x, prev_max_x} ->
        new_min_x = if min_x < prev_min_x, do: min_x, else: prev_min_x
        new_max_x = if max_x > prev_max_x, do: max_x, else: prev_max_x
        {new_min_x, new_max_x}
      end)

    Enum.map(min_y..max_y, fn y ->
      row = Map.get(grid, y)

      Enum.map(min_x..max_x, fn x ->
        char(Map.get(row, x, 0))
      end)
    end)
    |> Enum.each(&IO.puts(&1))

    # |> Enum.join("\n")
  end

  def part2 do
    %{grid: grid} =
      parse_file()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()
      |> do_work(%{x: 0, y: 0, direction: :up, grid: %{0 => %{0 => 1}}})

    grid
    |> render
  end
end
