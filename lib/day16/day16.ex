defmodule Advent.Day16 do
  @pattern_initial [0, 1, 0, -1]

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  @spec start_pattern_agent :: pid
  def start_pattern_agent do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    pid
  end

  @spec set_pattern(pid, {integer, integer}, list) :: :ok
  def set_pattern(pattern_agent, key, pattern) do
    :ok = Agent.update(pattern_agent, fn patterns -> Map.put(patterns, key, pattern) end)
  end

  def get_patterns(pattern_agent) do
    Agent.get(pattern_agent, fn patterns -> patterns end)
  end

  def get_pattern(pattern_agent, length, position) do
    key = {length, position}

    Agent.get(pattern_agent, fn patterns ->
      Map.get(patterns, key)
      |> case do
        nil ->
          {:set, create_pattern(length, position)}

        val ->
          {:get, val}
      end
    end)
    |> case do
      {:set, pattern} ->
        set_pattern(pattern_agent, key, pattern)
        pattern

      {:get, pattern} ->
        pattern
    end
  end

  defp duplicates(position), do: position + 1

  defp create_pattern(length, position) do
    dupes = duplicates(position)
    pattern_length = @pattern_initial |> Enum.count()

    [_ | new_pattern] =
      Enum.reduce(0..length, [], fn x, acc ->
        pattern_offset = rem(div(x, dupes), pattern_length)
        [Enum.at(@pattern_initial, pattern_offset)] ++ acc
      end)
      |> Enum.reverse()

    new_pattern
  end

  def calculate_value(pattern_agent, input, position \\ 0)

  def calculate_value(pattern_agent, input, position) when position < length(input) do
    length =
      input
      |> Enum.count()

    pattern = get_pattern(pattern_agent, length, position)

    value =
      input
      |> Enum.reduce({0, []}, fn x, {cur_pos, acc} ->
        multiplier = Enum.at(pattern, cur_pos)
        {cur_pos + 1, [multiplier * x] ++ acc}
      end)
      |> elem(1)
      |> Enum.sum()
      |> rem(10)
      |> abs()

    [value] ++ calculate_value(pattern_agent, input, position + 1)
  end

  def calculate_value(_, _, _), do: []

  def run(input, iterations) do
    pattern_agent = start_pattern_agent()

    result =
      Enum.reduce(0..(iterations - 1), input |> parse_input(), fn _, acc ->
        calculate_value(pattern_agent, acc)
      end)
      |> Enum.join("")
      |> String.slice(0, 8)

    Agent.stop(pattern_agent)
    result
  end

  def tests do
    "01029498" = run("12345678", 4)
    "24176176" = run("80871224585914546619083218645595", 100)
    "73745418" = run("19617804207202209144916044189917", 100)
    "52432133" = run("69317163492948606335995924319873", 100)
    :ok
  end

  def part1 do
    Advent.daily_input(16)
    |> run(100)
  end

  # value(digit, phase) = value(digit + 1, phase) + value(digit, phase - 1)
  def calculate(list) do
    calculate(Enum.reverse(list), [], 0)
  end

  def calculate([], output, _last_val) do
    output
  end

  def calculate([head | tail], output, last_val) do
    val = rem(head + last_val, 10)
    calculate(tail, [val | output], val)
  end

  def run2(input) do
    offset = Enum.take(input, 7) |> Integer.undigits()

    Stream.cycle(input)
    |> Stream.drop(offset)
    |> Enum.take(Enum.count(input) * 10000 - offset)
    |> Stream.iterate(&calculate/1)
    |> Enum.at(100)
    |> Enum.take(8)
    |> Integer.undigits()
  end

  def tests2 do
    84_462_026 = "03036732577212944063491565474664" |> parse_input() |> run2()
    :ok
  end

  def part2 do
    Advent.daily_input(16)
    |> parse_input()
    |> run2()
  end
end
