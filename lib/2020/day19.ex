defmodule Aoc202019 do
  def test_input,
    do: """
    0: 4 1 5
    1: 2 3 | 3 2
    2: 4 4 | 5 5
    3: 4 5 | 5 4
    4: "a"
    5: "b"

    ababbb
    bababa
    abbbab
    aaabbb
    aaaabbb
    """

  def test_input2,
    do: """
    42: 9 14 | 10 1
    9: 14 27 | 1 26
    10: 23 14 | 28 1
    1: "a"
    11: 42 31
    5: 1 14 | 15 1
    19: 14 1 | 14 14
    12: 24 14 | 19 1
    16: 15 1 | 14 14
    31: 14 17 | 1 13
    6: 14 14 | 1 14
    2: 1 24 | 14 4
    0: 8 11
    13: 14 3 | 1 12
    15: 1 | 14
    17: 14 2 | 1 7
    23: 25 1 | 22 14
    28: 16 1
    4: 1 1
    20: 14 14 | 1 15
    3: 5 14 | 16 1
    27: 1 6 | 14 18
    14: "b"
    21: 14 1 | 1 14
    25: 1 1 | 1 14
    22: 14 14
    8: 42
    26: 14 22 | 1 20
    18: 15 15
    7: 14 5 | 1 21
    24: 14 1

    abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
    bbabbbbaabaabba
    babbbbaabbbbbabbbbbbaabaaabaaa
    aaabbbbbbaaaabaababaabababbabaaabbababababaaa
    bbbbbbbaaaabbbbaaabbabaaa
    bbbababbbbaaaaaaaabbababaaababaabab
    ababaaaaaabaaab
    ababaaaaabbbaba
    baabbaaaabbaaaababbaababb
    abbbbabbbbaaaababbbbbbaaaababb
    aaaaabbaabaaaaababaa
    aaaabbaaaabbaaa
    aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
    babaaabbbaaabaababbaabababaaab
    aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
    """

  def parse_rules(rules) do
    replacements = Regex.scan(~r/(\d+): \"(.)\"/, rules)

    Enum.reduce(replacements, rules <> "\n", fn [line, id, value], acc ->
      {:ok, match} = Regex.compile("\\b#{id}(\\b)")

      acc
      |> String.replace(line <> "\n", "")
      |> String.replace(match, "#{value}")
    end)
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn row, acc ->
      [rule_id, sets] = String.split(row, ": ", trim: true)
      Map.put(acc, String.to_integer(rule_id), sets)
    end)
  end

  def parse(input) do
    [rules, messages] =
      input
      |> String.split("\n\n", trim: true)

    {
      parse_rules(rules),
      String.split(messages, "\n", trim: true)
    }
  end

  def build_regex(state, rules) do
    if Regex.match?(~r/[^{]\d+[^}]/, state) do
      {:ok, match} = Regex.compile("\\b(\\d+)(\\b)")

      [_line, id_str, _work_break] = Regex.run(match, state)

      {:ok, id_match} = Regex.compile("\\b#{id_str}(\\b)")

      id = String.to_integer(id_str)

      state
      |> String.replace(id_match, "(" <> rules[id] <> ")")
      |> build_regex(rules)
    else
      state |> String.replace(" ", "")
    end
  end

  def wrap_regex(str), do: "^" <> str <> "$"

  def part1({rules, messages}) do
    {:ok, regex} =
      build_regex(rules[0], Map.delete(rules, 0))
      |> wrap_regex()
      |> Regex.compile()

    messages
    |> Enum.reduce(0, fn message, acc ->
      if Regex.match?(regex, message), do: acc + 1, else: acc
    end)
  end

  def part2({rules, messages}) do
    rules =
      rules
      |> Map.put(8, "(42)+")
      # Yuck
      |> Map.put(
        11,
        "(42 31|42 42 31 31|42 42 42 31 31 31|42 42 42 42 31 31 31 31)"
      )

    {:ok, regex} =
      build_regex(rules[0], Map.delete(rules, 0))
      |> wrap_regex()
      |> Regex.compile()

    messages
    |> Enum.reduce(0, fn message, acc ->
      if Regex.match?(regex, message), do: acc + 1, else: acc
    end)
  end

  def run do
    test_input1 =
      test_input()
      |> parse()

    test_result1 = part1(test_input1)
    IO.puts("Solution to Test Part 1 (Should be 2): #{test_result1}")

    input =
      Advent.daily_input("2020", "19")
      |> parse()

    result1 = part1(input)
    IO.puts("Solution to Part 1: #{result1}")

    test_input_pt2 =
      test_input2()
      |> parse()

    test_result2 = part2(test_input_pt2)
    IO.puts("Solution to Test Part 2 (Should be 12): #{test_result2}")

    result2 = part2(input)
    IO.puts("Solution to Part 2: #{result2}")
    # 352 is too high
  end
end
