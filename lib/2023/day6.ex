defmodule Aoc202306 do
  defp parse(input) do
    ["Time: " <> times, "Distance: " <> distances] = String.split(input, "\n", trim: true)

    {String.split(times, " ", trim: true) |> Enum.map(&String.to_integer/1),
     String.split(distances, " ", trim: true) |> Enum.map(&String.to_integer/1)}
  end

  defp process({[], []}), do: []

  defp process({[time | times], [distance | distances]}) do
    count =
      Enum.reduce(0..(time - 1), [], fn hold, acc ->
        val = (time - hold) * hold

        if val > distance do
          [time] ++ acc
        else
          acc
        end
      end)
      |> Enum.count()

    [count] ++ process({times, distances})
  end

  defp part1(input) do
    [first | rest] =
      input
      |> process()

    Enum.reduce(rest, first, fn x, acc -> acc * x end)
  end

  defp part2(input) do
    {times, distances} = input
    time = times |> Enum.join("") |> String.to_integer()
    distance = distances |> Enum.join("") |> String.to_integer()

    Enum.reduce(0..(time - 1), [], fn hold, acc ->
      val = (time - hold) * hold

      if val > distance do
        [time] ++ acc
      else
        acc
      end
    end)
    |> Enum.count()
  end

  def run() do
    test_input =
      """
      Time:      7  15   30
      Distance:  9  40  200
      """
      |> parse()

    input =
      Advent.daily_input("2023", "06")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
