defmodule Aoc201920 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp translate("#"), do: :wall
  defp translate("."), do: :empty
  defp translate(" "), do: nil
  defp translate(char), do: char

  def to_map(input) do
    input
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {val, x}, output ->
        translate(val)
        |> case do
          nil -> output
          new_val -> Map.put(output, {x, y}, new_val)
        end
      end)
    end)
  end

  def neighbors({x, y}),
    do: [
      {x - 1, y, :west},
      {x, y - 1, :north},
      {x + 1, y, :east},
      {x, y + 1, :south}
    ]

  def build_neighbors(grid) do
    grid
    |> Enum.filter(fn {_key, value} -> value == :empty end)
    |> Enum.map(fn {at, _} ->
      clean_neighbors =
        neighbors(at)
        |> Enum.reduce([], fn {x, y, direction}, acc ->
          neighbor_pos = {x, y}

          grid
          |> Map.get(neighbor_pos)
          |> case do
            :wall ->
              acc

            val ->
              result =
                if not is_atom(val) && Regex.match?(~r/[A-Z]/, val) do
                  direction
                  |> case do
                    :north ->
                      Map.get(grid, {x, y - 1}) <> val

                    :south ->
                      val <> Map.get(grid, {x, y + 1})

                    :east ->
                      val <> Map.get(grid, {x + 1, y})

                    :west ->
                      Map.get(grid, {x - 1, y}) <> val
                  end
                  |> case do
                    "AA" -> :start
                    "ZZ" -> :end
                    portal -> {:portal, portal, at}
                  end
                else
                  neighbor_pos
                end

              [result | acc]
          end
        end)

      {at, clean_neighbors}
    end)
    |> Map.new()
  end

  def inner_or_outer(x, _y, _max_x, _max_y) when x <= 2, do: :outer
  def inner_or_outer(_x, y, _max_x, _max_y) when y <= 2, do: :outer
  def inner_or_outer(x, _y, max_x, _max_y) when x >= max_x - 2, do: :outer
  def inner_or_outer(_x, y, _max_x, max_y) when y >= max_y - 2, do: :outer
  def inner_or_outer(_, _, _, _), do: :inner

  def link_portals(map) do
    max_x =
      map
      |> Enum.map(fn {key, _value} -> key end)
      |> Enum.max(fn {x1, _y1}, {x2, _y2} -> x1 > x2 end)
      |> elem(0)

    max_y =
      map
      |> Enum.map(fn {key, _value} -> key end)
      |> Enum.max(fn {_x1, y1}, {_x2, y2} -> y1 > y2 end)
      |> elem(1)

    map
    |> Enum.reduce(%{}, fn {position, neighbors}, acc ->
      portal =
        Enum.find(neighbors, fn node ->
          node
          |> case do
            {:portal, _, _} -> true
            _ -> false
          end
        end)

      not_portals =
        Enum.filter(neighbors, fn node ->
          node
          |> case do
            {:portal, _, _} -> false
            _ -> true
          end
        end)

      new_neighbors =
        portal
        |> case do
          nil ->
            []

          {:portal, portal, {x, y} = at} ->
            Enum.find(map, fn {destination, neighbors} ->
              Enum.member?(neighbors, {:portal, portal, destination}) && at != destination
            end)
            |> case do
              {destination, _neighbors} ->
                [{:portal, inner_or_outer(x, y, max_x, max_y), destination}]

              result ->
                {:error, "No portal destination found", result}
            end
        end
        |> Enum.concat(not_portals)

      Map.put(acc, position, new_neighbors)
    end)
  end

  def find_start_end(map) do
    {start, _nodes} =
      Enum.find(map, fn {_key, nodes} ->
        Enum.member?(nodes, :start)
      end)

    {final, _nodes} =
      Enum.find(map, fn {_key, nodes} ->
        Enum.member?(nodes, :end)
      end)

    %{
      start: start,
      end: final,
      map: map
    }
  end

  def traverse(
        %{end: final, map: map} = maze,
        queue,
        recurse,
        visited \\ MapSet.new()
      ) do
    Advent.dequeue(queue)
    |> case do
      :empty ->
        {:error, "Ran out of work"}

      {x, y, level, steps} ->
        current_position = {x, y}

        cond do
          current_position == final && level == 0 ->
            steps

          true ->
            new_visited = MapSet.put(visited, {x, y, level})

            map
            |> Map.get(current_position)
            |> Enum.reject(&(&1 in [:start, :end]))
            |> Enum.reject(fn point ->
              key =
                point
                |> case do
                  {:portal, :outer, pt} ->
                    pt
                    |> Tuple.append(level - 1)

                  {:portal, :inner, pt} ->
                    pt
                    |> Tuple.append(level + 1)

                  _ ->
                    point
                    |> Tuple.append(level)
                end

              MapSet.member?(visited, key)
            end)
            |> case do
              [] ->
                nil

              neighbors ->
                Enum.each(neighbors, fn neighbor ->
                  neighbor
                  |> case do
                    {:portal, inner_outer, portal_to} ->
                      cond do
                        not recurse ->
                          Advent.enqueue(
                            queue,
                            Tuple.append(Tuple.append(portal_to, level), steps + 1)
                          )

                        true ->
                          cond do
                            inner_outer == :outer && level == 0 ->
                              :noop

                            inner_outer == :outer ->
                              Advent.enqueue(
                                queue,
                                Tuple.append(Tuple.append(portal_to, level - 1), steps + 1)
                              )

                            inner_outer == :inner ->
                              Advent.enqueue(
                                queue,
                                Tuple.append(Tuple.append(portal_to, level + 1), steps + 1)
                              )
                          end
                      end

                    _ ->
                      Advent.enqueue(
                        queue,
                        Tuple.append(Tuple.append(neighbor, level), steps + 1)
                      )
                  end
                end)
            end

            traverse(maze, queue, recurse, new_visited)
        end
    end
  end

  def do_work(input, recurse \\ false) do
    queue = Advent.start_queue_agent()

    clean_map =
      input
      |> parse()
      |> to_map()
      |> build_neighbors()
      |> link_portals()
      |> find_start_end()

    Advent.enqueue(queue, Tuple.append(Tuple.append(clean_map.start, 0), 0))

    clean_map
    |> traverse(queue, recurse)
  end

  def test1_part1 do
    Advent.daily_input("2019", "20-t1")
    |> do_work()
  end

  def test2_part1 do
    Advent.daily_input("2019", "20-t2")
    |> do_work()
  end

  def test1_part2 do
    Advent.daily_input("2019", "20-t1")
    |> do_work(true)
  end

  def test2_part2 do
    Advent.daily_input("2019", "20-t3")
    |> do_work(true)
  end

  def part1 do
    Advent.daily_input("2019", "20")
    |> do_work()
  end

  def part2 do
    Advent.daily_input("2019", "20")
    |> do_work(true)
  end

  def run do
    Advent.output(&test1_part1/0, "Test Part 1 Result (Should be 23): ")
    Advent.output(&test2_part1/0, "Test Part 1 Result (Should be 58): ")
    Advent.output(&part1/0, "Part 1 Result: ")
    Advent.output(&test1_part2/0, "Test Part 2 Result (Should be 26): ")
    Advent.output(&test2_part2/0, "Test Part 2 Result (Should be 396): ")
    Advent.output(&part2/0, "Part 2 Result: ")
  end
end
