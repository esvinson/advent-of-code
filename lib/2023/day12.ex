defmodule Aoc202312 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [field, runs] = String.split(row, " ", trim: true)

      runs =
        runs
        |> String.split(",", trim: true)
        |> Enum.map(fn val ->
          val = String.to_integer(val)
          String.duplicate("#", val)
        end)

      {:ok, regex} = Regex.compile("^[\\.]*" <> Enum.join(runs, "[\\.]+") <> "[\\.]*$")

      {regex, String.split(field, "", trim: true)}
    end)
  end

  defp parse2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [field, runs] = String.split(row, " ", trim: true)
      field = List.duplicate([field], 5) |> Enum.join("?")
      maximum = String.length(field)
      runs = List.duplicate([runs], 5) |> Enum.join(",")
      minimum = String.length(runs)
      regex = String.replace(field, "?", "[\\.#]")

      runs =
        runs
        |> String.split(",", trim: true)
        |> Enum.map(fn val ->
          val = String.to_integer(val)
          String.duplicate("#", val)
        end)

      {minimum, maximum, runs, regex}
    end)
  end

  defp process_row(regex, values) do
    Enum.reduce(values, [""], fn current, results ->
      Enum.map(results, fn result ->
        case current do
          "?" ->
            [result <> "#", result <> "."]

          "#" ->
            [result <> "#"]

          "." ->
            [result <> "."]
        end
      end)
      |> List.flatten()
    end)
    |> Enum.filter(fn pattern ->
      Regex.match?(regex, pattern)
    end)
    |> Enum.count()
  end

  defp part1(rows) do
    rows
    |> Enum.map(fn {regex, values} -> process_row(regex, values) end)
    |> Enum.sum()
  end

  defp part2(rows) do
    rows
    |> Enum.map(fn {minimum, maximum, runs, _regex} ->
      total_spaces = maximum - minimum
      total_gaps = Enum.count(runs) + 2
      {total_spaces, total_gaps}
    end)
  end

  def run() do
    test =
      """
      ???.### 1,1,3
      .??..??...?##. 1,1,3
      ?#?#?#?#?#?#?#? 1,3,1,6
      ????.#...#... 4,1,1
      ????.######..#####. 1,6,5
      ?###???????? 3,2,1
      """

    test_input = parse(test)

    test_input2 = parse2(test)

    input_raw = Advent.daily_input("2023", "12")
    input = parse(input_raw)
    input2 = parse2(input_raw)

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    # IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input2))}")
    IO.puts("Part 2: #{inspect(part2(input2))}")
  end
end
