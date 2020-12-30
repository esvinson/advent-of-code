defmodule Aoc201920 do
  def test_input,
    do: """
             A
             A
      #######.#########
      #######.........#
      #######.#######.#
      #######.#######.#
      #######.#######.#
      #####  B    ###.#
    BC...##  C    ###.#
      ##.##       ###.#
      ##...DE  F  ###.#
      #####    G  ###.#
      #########.#####.#
    DE..#######...###.#
      #.#########.###.#
    FG..#########.....#
      ###########.#####
                 Z
                 Z
    """

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

  def link_portals(map) do
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

          {:portal, portal, at} ->
            Enum.find(map, fn {destination, neighbors} ->
              Enum.member?(neighbors, {:portal, portal, destination}) && at != destination
            end)
            |> case do
              {destination, _neighbors} -> [destination]
              result -> {:error, "No portal destination found", result}
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
        visited \\ MapSet.new()
      ) do
    Advent.dequeue(queue)
    |> case do
      :empty ->
        {:error, "Ran out of work"}

      {x, y, depth} ->
        current_position = {x, y}

        cond do
          current_position == final ->
            depth

          true ->
            new_visited = MapSet.put(visited, current_position)

            map
            |> Map.get(current_position)
            |> Enum.reject(&(&1 in [:start, :end]))
            |> Enum.reject(&MapSet.member?(visited, &1))
            |> case do
              [] ->
                nil

              neighbors ->
                Enum.each(neighbors, fn neighbor ->
                  Advent.enqueue(queue, Tuple.append(neighbor, depth + 1))
                end)
            end

            traverse(maze, queue, new_visited)
        end
    end
  end

  def do_work(input) do
    queue = Advent.start_queue_agent()

    clean_map =
      input
      |> parse()
      |> to_map()
      |> build_neighbors()
      |> link_portals()
      |> find_start_end()

    Advent.enqueue(queue, Tuple.append(clean_map.start, 0))

    clean_map
    |> traverse(queue)
  end

  def test1_part1 do
    test_input()
    |> do_work()
  end

  def test2_part1 do
    Advent.daily_input("2019", "20-t2")
    |> do_work()
  end

  def part1 do
    Advent.daily_input("2019", "20")
    |> do_work()
  end

  def run do
    Advent.output(&test1_part1/0, "Test Part 1 Result (Should be 23): ")
    Advent.output(&test2_part1/0, "Test Part 1 Result (Should be 58): ")
    Advent.output(&part1/0, "Part 1 Result: ")
  end
end
