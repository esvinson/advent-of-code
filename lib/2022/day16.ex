defmodule Aoc202216 do
  def parse_valves(valve_string) do
    {:ok, regex} =
      "Valve (?<valve>\\w\\w) has flow rate=(?<rate>\\d+); tunnels? leads? to valves? (?<links>.*)"
      |> Regex.compile()

    regex
    |> Regex.named_captures(valve_string)
    |> Map.update("links", [], &String.split(&1, ", ", trim: true))
    |> Map.update("rate", [], &String.to_integer(&1))
    |> Map.put("state", :closed)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn valve_str, acc ->
      %{"valve" => valve} = valve_data = parse_valves(valve_str)
      Map.put(acc, valve, valve_data)
    end)
  end

  def calculate_release(valves) do
    Enum.reduce(valves, 0, fn {_key, valve}, acc ->
      case Map.get(valve, "state", 0) do
        :closed -> acc
        _ -> Map.get(valve, "rate", 0) + acc
      end
    end)
  end

  def valve_open?(valves, valve) do
    state =
      valves
      |> Map.get(valve)
      |> Map.get("state", :closed)

    state == :open
  end

  def open_valve(valves, valve) do
    cur_valve = Map.get(valves, valve)
    new_state = Map.put(cur_valve, "state", :open)
    Map.put(valves, valve, new_state)
  end

  def next_step(_valves, _prev, _cur_valve, 0, release), do: release

  def next_step(valves, cur_valve, prev_valve, time_left, release) do
    current = Map.get(valves, cur_valve)

    {Map.get(current, "rate", 0), Map.get(current, "state", :closed)}
    |> case do
      {0, _} ->
        current
        |> Map.get("links", [])
        |> Enum.reject(fn x -> x == prev_valve end)
        |> case do
          [] ->
            release

          links ->
            links
            |> Enum.map(fn next_valve ->
              new_release = calculate_release(valves)

              next_step(valves, next_valve, cur_valve, time_left - 1, release + new_release)
            end)
            |> Enum.max()
        end

      {_, :open} ->
        current
        |> Map.get("links", [])
        |> Enum.reject(fn x -> x == prev_valve end)
        |> case do
          [] ->
            release

          links ->
            links
            |> Enum.map(fn next_valve ->
              new_release = calculate_release(valves)

              next_step(valves, next_valve, cur_valve, time_left - 1, release + new_release)
            end)
            |> Enum.max()
        end

      _ ->
        new_release = calculate_release(valves)

        valves
        |> open_valve(cur_valve)
        |> next_step(cur_valve, cur_valve, time_left - 1, release + new_release)
    end
  end

  def part1(valves) do
    valves
    |> next_step("AA", "AA", 30, 0)
  end

  def run do
    test_input =
      """
      Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
      Valve BB has flow rate=13; tunnels lead to valves CC, AA
      Valve CC has flow rate=2; tunnels lead to valves DD, BB
      Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
      Valve EE has flow rate=3; tunnels lead to valves FF, DD
      Valve FF has flow rate=0; tunnels lead to valves EE, GG
      Valve GG has flow rate=0; tunnels lead to valves FF, HH
      Valve HH has flow rate=22; tunnel leads to valve GG
      Valve II has flow rate=0; tunnels lead to valves AA, JJ
      Valve JJ has flow rate=21; tunnel leads to valve II
      """
      |> parse()

    input = Advent.daily_input("2022", "16") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
