defmodule Advent.Day12 do
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn moon ->
      initial_moon =
        moon
        |> String.trim("<")
        |> String.trim(">")
        |> String.replace(~r/[xyz]=/, "")
        |> String.split(", ")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      {initial_moon, {0, 0, 0}}
    end)
  end

  def calculate_energy(moons) do
    Enum.reduce(moons, 0, fn {{x, y, z}, {velx, vely, velz}}, total ->
      potential = abs(x) + abs(y) + abs(z)
      kinetic = abs(velx) + abs(vely) + abs(velz)
      total + potential * kinetic
    end)
  end

  def test1 do
    initial_state =
      """
      <x=-1, y=0, z=2>
      <x=2, y=-10, z=-7>
      <x=4, y=-8, z=8>
      <x=3, y=5, z=-1>
      """
      |> parse_input()

    Enum.reduce(0..9, initial_state, fn _, moons ->
      moons
      |> adjust_velocities()
      |> apply_velocities()
    end)
    |> calculate_energy()
  end

  def test2 do
    initial_state =
      """
      <x=-8, y=-10, z=0>
      <x=5, y=5, z=10>
      <x=2, y=-7, z=3>
      <x=9, y=-8, z=-3>
      """
      |> parse_input()

    Enum.reduce(0..99, initial_state, fn _, moons ->
      moons
      |> adjust_velocities()
      |> apply_velocities()
    end)
    |> calculate_energy()
  end

  def adjust(a, b) when a > b, do: -1
  def adjust(a, b) when a < b, do: 1
  def adjust(a, b) when a == b, do: 0

  defp adjust_velocities(moons) do
    Enum.reduce(moons, [], fn {{x, y, z} = position, velocity}, new_moons ->
      new_velocity =
        moons
        |> Enum.filter(fn {subposition, _vel} -> subposition != position end)
        |> Enum.reduce(velocity, fn {{sub_x, sub_y, sub_z}, _vel}, {velx, vely, velz} ->
          {adjust(x, sub_x) + velx, adjust(y, sub_y) + vely, adjust(z, sub_z) + velz}
        end)

      [{position, new_velocity}] ++ new_moons
    end)
  end

  defp apply_velocities(moons) do
    Enum.reduce(moons, [], fn {{x, y, z}, {velx, vely, velz} = velocity}, new_moons ->
      [{{x + velx, y + vely, z + velz}, velocity}] ++ new_moons
    end)
  end

  def part1 do
    initial_state =
      Advent.daily_input(12)
      |> parse_input()

    Enum.reduce(0..999, initial_state, fn _, moons ->
      moons
      |> adjust_velocities()
      |> apply_velocities()
    end)
    |> calculate_energy()
  end

  def matches?(i, n) when i == n, do: true
  def matches?(_, _), do: false

  def get_x({{x, _, _}, {vx, _, _}}), do: {x, vx}
  def get_y({{_, y, _}, {_, vy, _}}), do: {y, vy}
  def get_z({{_, _, z}, {_, _, vz}}), do: {z, vz}

  def test1_part2 do
    """
    <x=-1, y=0, z=2>
    <x=2, y=-10, z=-7>
    <x=4, y=-8, z=8>
    <x=3, y=5, z=-1>
    """
    |> parse_input()
    |> solve2()
  end

  def test2_part2 do
    """
    <x=-8, y=-10, z=0>
    <x=5, y=5, z=10>
    <x=2, y=-7, z=3>
    <x=9, y=-8, z=-3>
    """
    |> parse_input()
    |> solve2()
  end

  def solve2(initial_state) do
    init_x = Enum.map(initial_state, &get_x/1)
    init_y = Enum.map(initial_state, &get_y/1)
    init_z = Enum.map(initial_state, &get_z/1)

    Enum.reduce_while(
      Stream.iterate(1, &(&1 + 1)),
      {initial_state, initial_state, {nil, nil, nil}},
      fn x, {initial_state, current_state, {ax, ay, az} = answer} ->
        new_state =
          current_state
          |> adjust_velocities()
          |> apply_velocities()

        new_x = Enum.map(new_state, &get_x/1)
        new_y = Enum.map(new_state, &get_y/1)
        new_z = Enum.map(new_state, &get_z/1)

        new_answer = if is_nil(ax) && matches?(init_x, new_x), do: {x, ay, az}, else: answer
        new_answer = if is_nil(ay) && matches?(init_y, new_y), do: {ax, x, az}, else: new_answer
        new_answer = if is_nil(az) && matches?(init_z, new_z), do: {ax, ay, x}, else: new_answer

        new_answer
        |> case do
          {ax, ay, az} when not is_nil(ax) and not is_nil(ay) and not is_nil(az) ->
            {:halt, new_answer}

          _ ->
            {:cont, {initial_state, new_state, new_answer}}
        end
      end
    )
    |> lcm()
  end

  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(a, b), do: div(abs(a * b), gcd(a, b))
  defp lcm({x, y, z}), do: lcm(x, lcm(y, z))

  def part2 do
    Advent.daily_input(12)
    |> parse_input()
    |> solve2()
  end
end
