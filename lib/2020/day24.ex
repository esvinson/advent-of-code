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

  # def part2(input) do
  # end

  def run do
    test_input1 = test_input() |> parse()
    IO.puts("Solution to Test Part 1 (Should be 10): #{inspect(part1(test_input1))}")
    # IO.puts("Solution to Test Part 1 (Should be 10): #{inspect(part2(test_input1))}")

    input =
      Advent.daily_input("2020", "24")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    # result2 = part2(input)
    # IO.puts("Solution to Part 2: #{result2}")
  end
end
