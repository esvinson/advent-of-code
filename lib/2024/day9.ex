defmodule Aoc202409 do
  defp parse(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp defrag_and_calculate(_, _, index, index), do: []

  defp defrag_and_calculate([:empty | _rest] = disk, [:empty | reversed], size, index),
    do: defrag_and_calculate(disk, reversed, size, index)

  defp defrag_and_calculate([:empty | disk], [rval | reversed], size, index),
    do: [rval * index] ++ defrag_and_calculate(disk, reversed, size, index + 1)

  defp defrag_and_calculate([val | disk], reversed, size, index),
    do: [val * index] ++ defrag_and_calculate(disk, reversed, size, index + 1)

  defp part1(input) do
    {_num, total_disk, disk_reverse} =
      input
      |> Enum.chunk_every(2)
      |> Enum.reduce(
        {0, 0, []},
        fn
          [data, empty], {num, data_acc, acc} ->
            data_set = for x <- 0..data, x > 0, do: num
            empty_set = for x <- 0..empty, x > 0, do: :empty
            {num + 1, data_acc + data, empty_set ++ data_set ++ acc}

          [data], {num, data_acc, acc} ->
            data_set = for x <- 0..data, x > 0, do: num
            {num, data_acc + data, data_set ++ acc}
        end
      )

    disk_fragmented = disk_reverse |> Enum.reverse()

    defrag_and_calculate(disk_fragmented, disk_reverse, total_disk, 0)
    |> Enum.sum()
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input = parse("2333133121414131402")

    input =
      Advent.daily_input("2024", "09")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
