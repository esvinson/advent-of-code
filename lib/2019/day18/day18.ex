defmodule Aoc201918 do
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

  def neighbors, do: [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]

  def build_neighbors(map) do
    map
    |> Enum.reduce(map, fn {{x, y} = pos, _value}, acc ->
      n =
        neighbors()
        |> Enum.reduce([], fn {dx, dy}, acc ->
          npos = {x + dx, y + dy}

          Map.get(map, npos, nil)
          |> case do
            nil -> acc
            _ -> [npos | acc]
          end
        end)

      Map.update(acc, pos, %{}, fn value ->
        Map.update(value, :neighbors, [], fn _old -> n end)
      end)
    end)
  end

  def output_to_map(graph) do
    graph
    |> to_string()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, index}, acc ->
      row_map =
        row
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {chr, index2}, acc2 ->
          chr
          |> type()
          |> case do
            :wall -> acc2
            type -> Map.put(acc2, {index2, index}, %{type: type, neighbors: []})
          end
        end)

      # {Map.merge(acc, row_map), Enum.count(row), index + 1}
      Map.merge(acc, row_map)
    end)
    |> build_neighbors()
  end

  def find_start(map) do
    map
    |> Enum.find(fn {_key, x} ->
      x.type == :start
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

    start = find_start(map)

    run_queue(map, start)
    |> find_paths()
  end

  def test2 do
    map =
      """
      ########################
      #f.D.E.e.C.b.A.@.a.B.c.#
      ######################.#
      #d.....................#
      ########################
      """
      |> output_to_map()

    start = find_start(map)

    run_queue(map, start)
    |> find_paths()
  end

  def test3 do
    map =
      """
      ########################
      #...............b.C.D.f#
      #.######################
      #.....@.a.B.c.d.A.e.F.g#
      ########################
      """
      |> output_to_map()

    start = find_start(map)

    run_queue(map, start)
    |> find_paths()
  end

  def test4 do
    map =
      """
      #################
      #i.G..c...e..H.p#
      ########.########
      #j.A..b...f..D.o#
      ########@########
      #k.E..a...g..B.n#
      ########.########
      #l.F..d...h..C.m#
      #################
      """
      |> output_to_map()

    start = find_start(map)

    run_queue(map, start)
    |> find_paths()
  end

  def test5 do
    map =
      """
      ########################
      #@..............ac.GI.b#
      ###d#e#f################
      ###A#B#C################
      ###g#h#i################
      ########################
      """
      |> output_to_map()

    start = find_start(map)

    run_queue(map, start)
    |> find_paths()
  end

  def directions(neighbors, distance, doors) do
    Enum.map(neighbors, fn neighbor ->
      neighbor
      |> Tuple.append(distance)
      |> Tuple.append(doors)
    end)
  end

  def run_queue(map, original_start) do
    keys =
      Enum.filter(map, fn {_pos, %{type: type}} ->
        type
        |> case do
          {:key, _} -> true
          _ -> false
        end
      end)

    starting_positions =
      keys
      |> Enum.reduce(%{"start" => original_start}, fn {pos, %{type: {:key, key}}}, acc ->
        Map.put(acc, key, pos)
      end)

    Enum.reduce(starting_positions, %{}, fn {key, start}, acc ->
      queue = Advent.start_queue_agent()

      map
      |> Map.get(start)
      |> Map.get(:neighbors)
      |> directions(1, MapSet.new())
      |> Enum.each(fn pos -> Advent.enqueue(queue, pos) end)

      key_depths =
        Stream.iterate(1, &(&1 + 1))
        |> Enum.reduce_while(
          {queue, MapSet.new([start]), %{}},
          fn _iteration, {queue_pid, visited, key_depth} ->
            queue_pid
            |> Advent.dequeue()
            |> case do
              :empty ->
                {:halt, key_depth}

              {x, y, depth, doors} ->
                position = {x, y}

                new_key_depth =
                  Map.get(map, position)
                  |> Map.get(:type)
                  |> case do
                    {:key, key} -> Map.put(key_depth, key, {depth, doors})
                    _ -> key_depth
                  end

                new_doors =
                  Map.get(map, position)
                  |> Map.get(:type)
                  |> case do
                    {:door, key} -> MapSet.put(doors, key)
                    _ -> doors
                  end

                map
                |> Map.get(position)
                |> Map.get(:neighbors)
                |> directions(depth + 1, new_doors)
                |> Enum.reject(fn {x, y, _, _} -> MapSet.member?(visited, {x, y}) end)
                |> Enum.each(fn pos -> Advent.enqueue(queue_pid, pos) end)

                new_visited = MapSet.put(visited, position)

                {:cont, {queue_pid, new_visited, new_key_depth}}
            end
          end
        )

      Map.put(acc, key, key_depths)
    end)
  end

  defp find_paths(distances) do
    start = Map.get(distances, "start")
    Advent.WeightedQueue.start_link()
    Advent.WeightedQueue.clear()

    all_keys =
      Map.keys(distances)
      |> MapSet.new()
      |> MapSet.delete("start")

    Enum.filter(start, fn {_key, {_distance, doors}} ->
      MapSet.size(doors) == 0
    end)
    |> Enum.each(fn {key, {distance, _}} ->
      Advent.WeightedQueue.enqueue({distance, key, all_keys |> MapSet.delete(key)})
    end)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(%{}, fn _iteration, visited ->
      Advent.WeightedQueue.dequeue()
      |> case do
        :empty ->
          {:halt, :not_found}

        {distance, key, remaining} ->
          if MapSet.size(remaining) == 0 do
            {:halt, distance}
          else
            Map.get(visited, {key, remaining}, false)
            |> case do
              val when val != false ->
                {:cont, visited}

              _ ->
                next_keys =
                  Map.get(distances, key)
                  |> Enum.filter(fn {_key, {_distance, doors}} ->
                    doors
                    |> MapSet.intersection(remaining)
                    |> MapSet.size() == 0
                  end)

                next_keys
                |> Enum.each(fn {door_key, {next_distance, _}} ->
                  nd = distance + next_distance
                  remaining_keys = MapSet.delete(remaining, door_key)
                  Advent.WeightedQueue.enqueue({nd, door_key, remaining_keys})
                end)

                MapSet.size(remaining)
                |> case do
                  0 ->
                    {:halt, distance}

                  _ ->
                    {:cont, Map.put(visited, {key, remaining}, distance)}
                end
            end
          end
      end
    end)
  end

  def part1 do
    map =
      Advent.daily_input("2019", "18")
      |> String.trim()
      |> output_to_map()

    start = find_start(map)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(map, fn _x, acc ->
      dead_ends =
        Enum.filter(acc, fn {_key, %{type: type, neighbors: neighbors}} ->
          type == :empty && Enum.count(neighbors) == 1
        end)

      dead_ends
      |> Enum.count()
      |> case do
        0 ->
          {:halt, acc}

        _ ->
          new_map =
            Enum.reduce(dead_ends, acc, fn {pos, %{neighbors: [neighbor]}}, subacc ->
              subacc
              |> Map.delete(pos)
              |> Map.update(neighbor, %{}, fn current ->
                Map.update(current, :neighbors, [], fn current_neighbors ->
                  Enum.reject(current_neighbors, fn x -> x == pos end)
                end)
              end)
            end)

          {:cont, new_map}
      end
    end)
    |> run_queue(start)
    |> find_paths()
  end

  def run do
    # Advent.output(&test1/0, "Test Part 1 (should be 8): ")
    # Advent.output(&test2/0, "Test Part 1 (should be 86): ")
    # Advent.output(&test3/0, "Test Part 1 (should be 132): ")
    # Advent.output(&test4/0, "Test Part 1 (should be 136): ")
    # Advent.output(&test5/0, "Test Part 1 (should be 81): ")
    Advent.output(&part1/0, "Part 1: ")
    # 3586 is too low
  end
end
