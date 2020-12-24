defmodule Aoc202024 do
  def test_input,
    do: """
    sesenwnenenewseeswwswswwnenewsewsw
    neeenesenwnwwswnenewnwwsewnenwseswesw
    seswneswswsenwwnwse
    nwnwneseeswswnenewneswwnewseswneseene
    swweswneswnenwsewnwneneseenw
    eesenwseswswnenwswnwnwsewwnwsene
    sewnenenenesenwsewnenwwwse
    wenwwweseeeweswwwnwwe
    wsweesenenewnwwnwsenewsenwwsesesenwne
    neeswseenwwswnwswswnw
    nenwswwsewswnenenewsenwsenwnesesenew
    enewnwewneswsewnwswenweswnenwsenwsw
    sweneswneswneneenwnewenewwneswswnese
    swwesenesewenwneswnwwneseswwne
    enesenwswwswneneswsenwnewswseenwsese
    wnwnesenesenenwwnenwsewesewsesesew
    nenewswnwewswnenesenwnesewesw
    eneswnwswnwsenenwnwnwwseeswneewsenese
    neswnwewnwnwseenwseesewsenwsweewe
    wseweeenwnesenwwwswnew
    """

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def calculate([], {x, y}), do: {x, y}
  def calculate(["n", "w" | rest], {x, y}), do: calculate(rest, {x - 1, y + 1})
  def calculate(["n", "e" | rest], {x, y}), do: calculate(rest, {x, y + 1})
  def calculate(["w" | rest], {x, y}), do: calculate(rest, {x - 1, y})
  def calculate(["e" | rest], {x, y}), do: calculate(rest, {x + 1, y})
  def calculate(["s", "w" | rest], {x, y}), do: calculate(rest, {x, y - 1})
  def calculate(["s", "e" | rest], {x, y}), do: calculate(rest, {x + 1, y - 1})

  def part1(input) do
    input
    |> Enum.map(&calculate(&1, {0, 0}))
    |> Enum.frequencies()
    |> Enum.filter(fn {_key, value} -> rem(value, 2) == 1 end)
    |> Enum.count()
  end

  @neighbors [{-1, 1}, {0, 1}, {-1, 0}, {1, 0}, {0, -1}, {1, -1}]

  def flip_tiles(state, 0), do: state

  def flip_tiles(state, iteration) do
    Enum.reduce(state, MapSet.new(), fn {{x, y}, _}, acc ->
      acc
      |> MapSet.put({x, y})
      |> MapSet.union(
        MapSet.new(Enum.map(@neighbors, fn {setx, sety} -> {x + setx, y + sety} end))
      )
    end)
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      Enum.reduce(@neighbors, 0, fn {setx, sety}, acc ->
        if Map.get(state, {x + setx, y + sety}, false) do
          acc + 1
        else
          acc
        end
      end)
      |> case do
        2 -> Map.put(acc, {x, y}, true)
        1 -> Map.put(acc, {x, y}, Map.get(state, {x, y}, false))
        _ -> acc
      end
    end)
    |> Enum.filter(fn {_key, val} -> val end)
    |> Map.new()
    |> flip_tiles(iteration - 1)
  end

  def part2(input) do
    day0 =
      input
      |> Enum.map(&calculate(&1, {0, 0}))
      |> Enum.frequencies()
      |> Enum.filter(fn {_key, value} -> rem(value, 2) == 1 end)
      |> Enum.reduce(%{}, fn {key, _}, acc -> Map.put(acc, key, true) end)

    flip_tiles(day0, 100)
    |> Enum.count()
  end

  def run do
    test_input1 = test_input() |> parse()
    IO.puts("Solution to Test Part 1 (Should be 10): #{inspect(part1(test_input1))}")
    IO.puts("Solution to Test Part 1 (Should be 10): #{inspect(part2(test_input1))}")

    input =
      Advent.daily_input("2020", "24")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
