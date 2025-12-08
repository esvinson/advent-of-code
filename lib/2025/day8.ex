defmodule Aoc202508 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp threed_distance({x1, y1, z1}, {x2, y2, z2}) do
    :math.sqrt(Integer.pow(x2 - x1, 2) + Integer.pow(y2 - y1, 2) + Integer.pow(z2 - z1, 2))
  end

  defp build_list([_last]), do: []

  defp build_list([first | rest]) do
    rest
    |> Enum.reduce([], fn x, acc ->
      [{threed_distance(first, x), first, x}] ++ acc
    end)
    |> Kernel.++(build_list(rest))
  end

  defp link([], sets, _single_set), do: sets

  defp link([{_distance, p1, p2} | points], sets, single_set) do
    if MapSet.member?(single_set, p1) && MapSet.member?(single_set, p2) do
      new_single_set =
        single_set
        |> MapSet.delete(p1)
        |> MapSet.delete(p2)

      new_set = MapSet.new([p1, p2])
      new_sets = [new_set] ++ sets
      link(points, new_sets, new_single_set)
    else
      if MapSet.member?(single_set, p1) do
        # p2 is in a set, p1 is not
        new_single_set =
          single_set
          |> MapSet.delete(p1)

        new_sets =
          Enum.reduce(sets, [], fn set, acc ->
            updated_set =
              if MapSet.member?(set, p2) do
                MapSet.put(set, p1)
              else
                set
              end

            [updated_set] ++ acc
          end)

        link(points, new_sets, new_single_set)
      else
        if MapSet.member?(single_set, p2) do
          new_single_set =
            single_set
            |> MapSet.delete(p2)

          # p1 is in a set, p2 is not
          new_sets =
            Enum.reduce(sets, [], fn set, acc ->
              updated_set =
                if MapSet.member?(set, p1) do
                  MapSet.put(set, p2)
                else
                  set
                end

              [updated_set] ++ acc
            end)

          link(points, new_sets, new_single_set)
        else
          # both in sets
          {p1set, p2set, new_sets} =
            Enum.reduce(sets, {nil, nil, []}, fn set, {p1set, p2set, acc} ->
              p1set =
                if MapSet.member?(set, p1) do
                  set
                else
                  p1set
                end

              p2set =
                if MapSet.member?(set, p2) do
                  set
                else
                  p2set
                end

              output_set =
                if MapSet.member?(set, p1) or MapSet.member?(set, p2), do: acc, else: [set] ++ acc

              {p1set, p2set, output_set}
            end)

          link(points, [MapSet.union(p1set, p2set)] ++ new_sets, single_set)
        end
      end
    end
  end

  defp part1(points, how_many) do
    single_set = MapSet.new(points)

    build_list(points)
    |> Enum.sort()
    |> Enum.take(how_many)
    |> link([], single_set)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  # defp part2(input) do
  #   input
  # end

  def run() do
    test_input =
      """
      162,817,812
      57,618,57
      906,360,560
      592,479,940
      352,342,300
      466,668,158
      542,29,236
      431,825,988
      739,650,466
      52,470,668
      216,146,977
      819,987,18
      117,168,530
      805,96,715
      346,949,466
      970,615,88
      941,993,340
      862,61,35
      984,92,344
      425,690,689
      """
      |> parse()

    input =
      Advent.daily_input("2025", "08")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input, 10), charlists: :as_lists)}")
    IO.puts("Part 1: #{inspect(part1(input, 1000), charlists: :as_lists)}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input), charlists: :as_lists)}")
    # IO.puts("Part 2: #{inspect(part2(input), charlists: :as_lists)}")
  end
end
