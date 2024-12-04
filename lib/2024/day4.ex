defmodule Aoc202404 do
  defp parse(input) do
    [first | _rest] =
      start =
      input
      |> String.split("\n", trim: true)

    max_y = Enum.count(start)
    max_x = String.length(first)

    map =
      start
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc1 ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc1, fn {val, x}, acc2 ->
          Map.put(acc2, {x, y}, val)
        end)
      end)

    %{map: map, height: max_y, width: max_x}
  end

  defp word(map, x, y, :west),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x - 1, y}),
        Map.get(map, {x - 2, y}),
        Map.get(map, {x - 3, y})
      ])

  defp word(map, x, y, :northwest),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x - 1, y - 1}),
        Map.get(map, {x - 2, y - 2}),
        Map.get(map, {x - 3, y - 3})
      ])

  defp word(map, x, y, :north),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x, y - 1}),
        Map.get(map, {x, y - 2}),
        Map.get(map, {x, y - 3})
      ])

  defp word(map, x, y, :northeast),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x + 1, y - 1}),
        Map.get(map, {x + 2, y - 2}),
        Map.get(map, {x + 3, y - 3})
      ])

  defp word(map, x, y, :east),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x + 1, y}),
        Map.get(map, {x + 2, y}),
        Map.get(map, {x + 3, y})
      ])

  defp word(map, x, y, :southeast),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x + 1, y + 1}),
        Map.get(map, {x + 2, y + 2}),
        Map.get(map, {x + 3, y + 3})
      ])

  defp word(map, x, y, :south),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x, y + 1}),
        Map.get(map, {x, y + 2}),
        Map.get(map, {x, y + 3})
      ])

  defp word(map, x, y, :southwest),
    do:
      Enum.join([
        Map.get(map, {x, y}),
        Map.get(map, {x - 1, y + 1}),
        Map.get(map, {x - 2, y + 2}),
        Map.get(map, {x - 3, y + 3})
      ])

  defp find_words(map, {x, y}, width, height) do
    Enum.filter(
      [
        if(x > 2, do: word(map, x, y, :west), else: false),
        if(x > 2 and y > 2, do: word(map, x, y, :northwest), else: false),
        if(y > 2, do: word(map, x, y, :north), else: false),
        if(x < width - 3 and y > 2, do: word(map, x, y, :northeast), else: false),
        if(x < width - 3, do: word(map, x, y, :east), else: false),
        if(x < width - 3 and y < height - 3, do: word(map, x, y, :southeast), else: false),
        if(y < height - 3, do: word(map, x, y, :south), else: false),
        if(x > 2 and y < height - 3, do: word(map, x, y, :southwest), else: false)
      ],
      fn x -> x end
    )
  end

  defp part1(%{map: map, width: width, height: height}) do
    positions = for x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}

    results =
      Enum.reduce(positions, %{}, fn pos, acc ->
        find_words(map, pos, width, height)
        |> Enum.reduce(acc, fn word, acc2 ->
          Map.update(acc2, word, 1, fn val -> val + 1 end)
        end)
      end)

    Map.get(results, "XMAS")
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      MMMSXXMASM
      MSAMXMSMSA
      AMXSXMAAMM
      MSAMASMSMX
      XMASAMXAMM
      XXAMMXXAMA
      SMSMSASXSS
      SAXAMASAAA
      MAMMMXMMMM
      MXMXAXMASX
      """
      |> parse()

    input =
      Advent.daily_input("2024", "04")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
