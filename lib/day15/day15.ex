defmodule Advent.Day15 do
  alias Advent.Opcodes

  @spec start_queue_agent :: pid
  def start_queue_agent do
    {:ok, pid} = Agent.start_link(fn -> :queue.new() end)
    pid
  end

  @spec enqueue(pid, {integer, integer}, map) :: :ok
  def enqueue(queue_agent, position, state) do
    :ok = Agent.update(queue_agent, fn queue -> :queue.in({position, state}, queue) end)
  end

  @spec update_queue(pid, any) :: :ok
  def update_queue(queue_agent, queue) do
    :ok = Agent.update(queue_agent, fn _old_queue -> queue end)
  end

  def clear_queue(queue_agent) do
    :ok = Agent.update(queue_agent, fn _queue -> :queue.new() end)
  end

  @spec dequeue(pid) :: :empty | {{integer, integer}, map}
  def dequeue(queue_agent) do
    {raw_value, new_queue} =
      Agent.get(queue_agent, fn queue ->
        :queue.out(queue)
      end)

    Agent.update(queue_agent, fn _old_queue -> new_queue end)

    raw_value
    |> case do
      {:value, value} -> value
      _ -> raw_value
    end
  end

  @spec start_visited_agent :: pid
  def start_visited_agent do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    pid
  end

  @spec is_visited?(pid, {integer, integer}) :: boolean
  def is_visited?(visted_agent, position) do
    Agent.get(visted_agent, fn visted -> Map.has_key?(visted, position) end)
  end

  @spec set_visited(pid, {integer, integer}, atom) :: :ok
  def set_visited(visted_agent, position, type) do
    :ok = Agent.update(visted_agent, fn visted -> Map.put(visted, position, type) end)
  end

  def set_empty_as_unvisited(visited_agent) do
    :ok =
      Agent.update(visited_agent, fn visited ->
        Enum.reduce(visited, %{}, fn {pos, value}, acc ->
          if value == :empty do
            acc
          else
            Map.put(acc, pos, value)
          end
        end)
      end)
  end

  def get_visited(visited_agent) do
    Agent.get(visited_agent, fn visited -> visited end)
  end

  @spec parse_file(String.t()) :: [integer]
  def parse_file(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def enqueue_neighbors(state, queue_agent, visited_agent) do
    current_location = Map.get(state, :position)

    Enum.each([:north, :south, :west, :east], fn direction ->
      new_xy = adjust_location(current_location, direction)

      if is_visited?(visited_agent, new_xy) do
        nil
      else
        new_state = Map.put(state, :direction, direction)
        enqueue(queue_agent, current_location, new_state)
      end
    end)
  end

  def run_queue(queue_agent, visited_agent, run_full \\ false) do
    dequeue(queue_agent)
    |> case do
      :empty ->
        {:halt, "No work left"}

      {position, %{direction: direction} = state} ->
        new_xy = adjust_location(position, direction)

        is_visited?(visited_agent, new_xy)
        |> case do
          true ->
            :cont

          _ ->
            state
            |> Map.put(:input, [direction(direction)])
            |> Opcodes.parse()
            |> case do
              {_, %{output: [0 | _rest]}} ->
                set_visited(visited_agent, new_xy, type(0))
                :cont

              {_, %{output: [1 | _rest]} = new_state} ->
                set_visited(visited_agent, new_xy, type(1))
                current_path = Map.get(state, :path, [])
                # moved
                new_state
                |> Map.put(:position, new_xy)
                |> Map.put(:path, [new_xy] ++ current_path)
                |> enqueue_neighbors(queue_agent, visited_agent)

                :cont

              {_, %{output: [2 | _rest]} = new_state} ->
                set_visited(visited_agent, new_xy, type(2))
                current_path = Map.get(state, :path, [])

                final_state =
                  new_state
                  |> Map.put(:position, new_xy)
                  |> Map.put(:path, [new_xy] ++ current_path)

                # Found!
                if run_full do
                  final_state
                  |> enqueue_neighbors(queue_agent, visited_agent)

                  :cont
                else
                  {:halt, final_state}
                end
            end
        end
    end
    |> case do
      {:halt, state} ->
        state

      :cont ->
        run_queue(queue_agent, visited_agent, run_full)
    end
  end

  @spec part1 :: integer
  def part1 do
    initial_state =
      Advent.daily_input(15)
      |> parse_file()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()
      |> Map.put(:position, {0, 0})
      |> Map.put(:path, [])

    queue_agent = start_queue_agent()
    visited_agent = start_visited_agent()
    set_visited(visited_agent, {0, 0}, :empty)
    enqueue_neighbors(initial_state, queue_agent, visited_agent)

    %{path: path} = run_queue(queue_agent, visited_agent)

    get_visited(visited_agent)
    |> draw()

    Enum.count(path)
  end

  @spec part2 :: integer
  def part2 do
    initial_state =
      Advent.daily_input(15)
      |> parse_file()
      |> Opcodes.list_to_map()
      |> Opcodes.registers_to_new_state()
      |> Map.put(:position, {0, 0})
      |> Map.put(:path, [])

    queue_agent = start_queue_agent()
    visited_agent = start_visited_agent()
    set_visited(visited_agent, {0, 0}, :empty)
    enqueue_neighbors(initial_state, queue_agent, visited_agent)

    run_queue(queue_agent, visited_agent, true)

    grid = get_visited(visited_agent)

    draw(grid)

    {starting_position, _} = grid |> Enum.find(fn {_pos, x} -> x == :oxygen_system end)
    set_empty_as_unvisited(visited_agent)

    %{position: starting_position, path: []}
    |> enqueue_neighbors(queue_agent, visited_agent)

    walk_path(queue_agent, visited_agent, 0)
  end

  def walk_path(queue_agent, visited_agent, distance) do
    dequeue(queue_agent)
    |> case do
      :empty ->
        {:halt, distance}

      {position, %{direction: direction} = state} ->
        new_xy = adjust_location(position, direction)

        is_visited?(visited_agent, new_xy)
        |> case do
          true ->
            {:cont, distance}

          _ ->
            set_visited(visited_agent, new_xy, type(1))
            current_path = Map.get(state, :path, [])
            new_path = [new_xy] ++ current_path
            # moved
            state
            |> Map.put(:position, new_xy)
            |> Map.put(:path, new_path)
            |> enqueue_neighbors(queue_agent, visited_agent)

            {:cont, Enum.count(new_path)}
        end
    end
    |> case do
      {:halt, state} ->
        state

      {:cont, new_distance} ->
        walk_path(queue_agent, visited_agent, new_distance)
    end
  end

  @spec direction(atom) :: integer
  defp direction(:north), do: 1
  defp direction(:south), do: 2
  defp direction(:west), do: 3
  defp direction(:east), do: 4

  @spec type(integer) :: atom
  defp type(0), do: :wall
  defp type(1), do: :empty
  defp type(2), do: :oxygen_system

  defp adjust_location({x, y}, :north), do: {x, y + 1}
  defp adjust_location({x, y}, :south), do: {x, y - 1}
  defp adjust_location({x, y}, :west), do: {x - 1, y}
  defp adjust_location({x, y}, :east), do: {x + 1, y}

  def char(:empty), do: " "
  def char(:wall), do: "#"
  def char(:oxygen_system), do: "O"

  def draw(grid) do
    {{min_x, _}, _} = Enum.min_by(grid, fn {{x, _y}, _val} -> x end)
    {{max_x, _}, _} = Enum.max_by(grid, fn {{x, _y}, _val} -> x end)

    {{_, min_y}, _} = Enum.min_by(grid, fn {{_x, y}, _val} -> y end)
    {{_, max_y}, _} = Enum.max_by(grid, fn {{_x, y}, _val} -> y end)

    Enum.map(min_y..max_y, fn y ->
      Enum.map(min_x..max_x, fn x ->
        char(Map.get(grid, {x, y}, :empty))
      end)
      |> Enum.join("")
    end)
    |> Enum.each(&IO.puts(&1))
  end
end
