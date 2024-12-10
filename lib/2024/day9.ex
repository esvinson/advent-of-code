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

  defp combine_empty([row]), do: [row]

  defp combine_empty([{_index, :empty, 0} | rest]), do: combine_empty(rest)

  defp combine_empty([{index, :empty, count}, {_index2, :empty, count2} | rest]),
    do: combine_empty([{index, :empty, count + count2}] ++ rest)

  defp combine_empty([item1, item2 | rest]), do: [item1] ++ combine_empty([item2] ++ rest)

  defp defrag2(disk, []), do: disk

  defp defrag2(disk, [{rindex, rval, rcount} | reverse]) do
    new_disk =
      Enum.reduce(disk, {false, []}, fn {index, val, count} = row, {found, acc} ->
        if found do
          if rval == val do
            {found, [{index, :empty, count}] ++ acc}
          else
            {found, [row] ++ acc}
          end
        else
          if val == :empty do
            if rcount <= count and index < rindex do
              if rcount == count do
                {true, [{index, rval, rcount}] ++ acc}
              else
                {true, [{index + rcount, :empty, count - rcount}, {index, rval, rcount}] ++ acc}
              end
            else
              {found, [row] ++ acc}
            end
          else
            {found, [row] ++ acc}
          end
        end
      end)
      |> elem(1)
      |> Enum.reverse()
      |> combine_empty()

    defrag2(new_disk, reverse)
  end

  defp part2(input) do
    {_num, _index, disk_reverse} =
      input
      |> Enum.chunk_every(2)
      |> Enum.reduce(
        {0, 0, []},
        fn
          [data, empty], {num, index, acc} ->
            {num + 1, index + data + empty,
             [{index + data, :empty, empty}, {index, num, data}] ++ acc}

          [data], {num, index, acc} ->
            {num + 1, index + data, [{index, num, data}] ++ acc}
        end
      )

    disk_fragmented = disk_reverse |> Enum.reverse()

    reverse =
      disk_reverse
      |> Enum.filter(fn
        {_, :empty, _} -> false
        {_, _, _} -> true
      end)

    defrag2(disk_fragmented, reverse)
    |> Enum.reduce(0, fn
      {_, :empty, _}, acc ->
        acc

      {index, id, count}, acc ->
        items = for i <- index..(index + count - 1), do: i * id
        acc + Enum.sum(items)
    end)
  end

  def run() do
    test_input = parse("2333133121414131402")

    input =
      Advent.daily_input("2024", "09")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input), charlists: :as_lists)}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
