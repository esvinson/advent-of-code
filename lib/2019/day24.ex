defmodule Aoc201924 do
  def translate("#"), do: :bug
  def translate("."), do: :empty

  def neighbors, do: [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {val, x}, subacc ->
        Map.put(subacc, {x, y}, translate(val))
      end)
    end)
  end

  def transform(state) do
    Enum.reduce(state, %{}, fn {{x, y} = pos, val}, acc ->
      total_neighbor_bugs =
        Enum.reduce(neighbors(), 0, fn {setx, sety}, total_bugs ->
          Map.get(state, {x + setx, y + sety}, :empty)
          |> case do
            :bug -> total_bugs + 1
            _ -> total_bugs
          end
        end)

      new_val =
        case val do
          :bug ->
            if total_neighbor_bugs == 1, do: :bug, else: :empty

          :empty ->
            if total_neighbor_bugs in [1, 2], do: :bug, else: :empty
        end

      Map.put(acc, pos, new_val)
    end)
  end

  def do_work(state, previous_states \\ MapSet.new()) do
    if MapSet.member?(previous_states, state) do
      state
    else
      previous_states = MapSet.put(previous_states, state)

      transform(state)
      |> do_work(previous_states)
    end
  end

  def calculate_biodiversity(state) do
    state
    |> Enum.filter(fn {_key, val} -> val == :bug end)
    |> Enum.reduce(0, fn {{x, y}, :bug}, acc ->
      acc + :math.pow(2, y * 5 + x)
    end)
    |> floor()
  end

  def test1 do
    test_input()
    |> parse()
    |> do_work()
    |> calculate_biodiversity()
  end

  def part1 do
    Advent.daily_input("2019", "24")
    |> parse()
    |> do_work()
    |> calculate_biodiversity()
  end

  def run do
    Advent.output(&test1/0, "Test 1 Result (Expect 2129920):")
    Advent.output(&part1/0, "Part 1 Result:")
  end

  def test_input,
    do: """
    ....#
    #..#.
    #..##
    ..#..
    #....
    """
end
