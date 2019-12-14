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

  def part2 do
    Advent.daily_input(12)
    |> parse_input()
  end
end
