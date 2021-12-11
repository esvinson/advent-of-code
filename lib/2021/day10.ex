defmodule Aoc202110 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
    end)
  end

  defp run_stack(queue, stack \\ [])

  defp run_stack([left | rest], stack) when left in ["(", "[", "<", "{"],
    do: run_stack(rest, [left] ++ stack)

  defp run_stack([left | rest], [stack_left | stack]) when left == ")" and stack_left == "(",
    do: run_stack(rest, stack)

  defp run_stack([left | _rest], [stack_left | _stack]) when left == ")" and stack_left != "(",
    do: {:error, left}

  defp run_stack([left | rest], [stack_left | stack]) when left == "]" and stack_left == "[",
    do: run_stack(rest, stack)

  defp run_stack([left | _rest], [stack_left | _stack]) when left == "]" and stack_left != "[",
    do: {:error, left}

  defp run_stack([left | rest], [stack_left | stack]) when left == ">" and stack_left == "<",
    do: run_stack(rest, stack)

  defp run_stack([left | _rest], [stack_left | _stack]) when left == ">" and stack_left != "<",
    do: {:error, left}

  defp run_stack([left | rest], [stack_left | stack]) when left == "}" and stack_left == "{",
    do: run_stack(rest, stack)

  defp run_stack([left | _rest], [stack_left | _stack]) when left == "}" and stack_left != "{",
    do: {:error, left}

  defp run_stack([], stack), do: stack

  defp score({:error, ")"}), do: 3
  defp score({:error, "]"}), do: 57
  defp score({:error, "}"}), do: 1197
  defp score({:error, ">"}), do: 25137

  def part1(rows) do
    rows
    |> Enum.map(fn row ->
      run_stack(row)
    end)
    |> Enum.filter(fn
      {:error, _} -> true
      _ -> false
    end)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  defp score_part2(")"), do: 1
  defp score_part2("]"), do: 2
  defp score_part2("}"), do: 3
  defp score_part2(">"), do: 4

  defp autocomplete(stack, result \\ [])

  defp autocomplete([], result), do: result

  defp autocomplete([left | rest], result) when left == "[",
    do: autocomplete(rest, ["]"] ++ result)

  defp autocomplete([left | rest], result) when left == "{",
    do: autocomplete(rest, ["}"] ++ result)

  defp autocomplete([left | rest], result) when left == "(",
    do: autocomplete(rest, [")"] ++ result)

  defp autocomplete([left | rest], result) when left == "<",
    do: autocomplete(rest, [">"] ++ result)

  def part2(rows) do
    result =
      rows
      |> Enum.map(fn row ->
        run_stack(row)
      end)
      |> Enum.filter(fn
        {:error, _} -> false
        _ -> true
      end)
      |> Enum.map(&autocomplete/1)
      |> Enum.map(fn row ->
        row
        |> Enum.map(&score_part2/1)
        |> Enum.reverse()
        |> Enum.reduce(0, fn x, acc -> 5 * acc + x end)
      end)
      |> Enum.sort()

    count = Enum.count(result)
    offset = div(count, 2) + rem(count, 2)
    Enum.at(result, offset - 1)
  end

  def run do
    test_input =
      """
      [({(<(())[]>[[{[]{<()<>>
      [(()[<>])]({[<{<<[]>>(
      {([(<{}[<>[]}>{[]{[(<()>
      (((({<>}<{<{<>}{[]{[]{}
      [[<[([]))<([[{}[[()]]]
      [{[{({}]{}}([{[{{{}}([]
      {<[[]]>}<{[{[{[]{()[[[]
      [<(<(<(<{}))><([]([]()
      <{([([[(<>()){}]>(<<{{
      <{([{{}}[<[[[<>{}]]]>[]]
      """
      |> parse()

    input =
      Advent.daily_input("2021", "10")
      |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
