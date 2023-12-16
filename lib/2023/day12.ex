defmodule Aoc202312 do
  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [field, runs] = String.split(row, " ", trim: true)

      {:ok, regex} =
        ("^" <> field <> "$")
        |> String.replace("?", "[#.]")
        |> String.replace(".", "\\.")
        |> Regex.compile()

      runs =
        runs
        |> String.split(",", trim: true)
        |> Enum.map(fn val ->
          val = String.to_integer(val)
          String.duplicate("#", val)
        end)

      {:ok, regex2} = Regex.compile("^[\\.]*" <> Enum.join(runs, "[\\.]+") <> "[\\.]*$")

      {regex, regex2, String.split(field, "", trim: true)}
    end)
  end

  defp process_row(regex, regex2, values) do
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
      Regex.match?(regex, pattern) and Regex.match?(regex2, pattern)
    end)
    |> Enum.count()
  end

  defp part1(rows) do
    rows
    |> Enum.map(fn {regex, regex2, values} -> process_row(regex, regex2, values) end)
    |> Enum.sum()
  end

  # defp part2(rows) do
  #   rows
  # end

  def run() do
    test_input =
      """
      ???.### 1,1,3
      .??..??...?##. 1,1,3
      ?#?#?#?#?#?#?#? 1,3,1,6
      ????.#...#... 4,1,1
      ????.######..#####. 1,6,5
      ?###???????? 3,2,1
      """
      |> parse()

    input =
      Advent.daily_input("2023", "12")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
