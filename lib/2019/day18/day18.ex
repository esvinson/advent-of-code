defmodule Advent.Day18 do
  def type("#"), do: :wall
  def type("."), do: :empty
  def type("@"), do: :start

  def type(chr) do
    cond do
      String.match?(chr, ~r/[A-Z]/) ->
        {:door, String.downcase(chr)}

      String.match?(chr, ~r/[a-z]/) ->
        {:key, chr}

      true ->
        raise "Unexpected character #{chr}"
    end
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
          Map.put(acc2, {index2, index}, type(chr))
        end)

      {Map.merge(acc, row_map), Enum.count(row), index + 1}
    end)
  end

  def find_start(map) do
    map
    |> Enum.find(fn {_key, x} ->
      x == :start
    end)
    |> elem(0)
  end

  def test1 do
    map =
      """
      #########
      #b.A.@.a#
      #########
      """
      |> output_to_map()

    map |> elem(0) |> find_start()
  end

  def directions({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y - 1}, {x, y + 1}]
  end

  def movable?(map, %{visited: visited, keys: keys} = state, position) do
    Map.get(map, position)
    |> case do
      :wall ->
        false

      {:door, door} ->
        Map.get(visited, position, false)
        |> case do
          false -> Map.get(keys, door, false)
          true -> false
        end

      {:key, _key} ->
        Map.get(visited, position, false)

      :start ->
        Map.get(visited, position, false)
    end
  end

  def enqueue_neighbors(state, map) do
    state
    |> Map.get(:position)
    |> directions()
    |> Enum.reduce(%{}, fn position, acc ->
      movable?(map, state, position)
      |> case do
        true ->
          state
          # |> Map
      end
    end)
  end

  def run_queue(queue, map) do
    # enqueue_neighbors(initial_state, queue_agent, visited_agent)
  end

  def part1 do
    map =
      Advent.daily_input(18)
      |> String.trim()
      |> output_to_map()

    start = map |> elem(0) |> find_start()

    initial_state = %{
      position: start,
      visited: %{start => true},
      keys: %{}
    }

    enqueue_neighbors(initial_state, map)
    |> run_queue(map)

    # Start at entrance (@)
    # BFS though all possible paths, have visited matrix attached to each worker
    # clear visited list when a key is picked up
    # current keys are stored with worker
    # need to use a :queue
  end
end
