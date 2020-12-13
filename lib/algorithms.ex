defmodule Advent.Algorithms do
  def lcm(a, b), do: div(abs(a * b), Integer.gcd(a, b))
  def lcm([first | list]), do: Enum.reduce(list, first, fn x, acc -> lcm(x, acc) end)

  # Extended GCD
  def egcd(_, 0), do: {1, 0}

  def egcd(a, b) do
    {s, t} = egcd(b, rem(a, b))
    {t, s - div(a, b) * t}
  end

  # Calculate the inverse modulo
  def mod_inv(a, b) do
    {x, y} = egcd(a, b)
    if a * x + b * y == 1, do: x, else: nil
  end

  # Modified rem that handles converting negative results to positive
  def mod(a, m) do
    x = rem(a, m)
    if x < 0, do: x + m, else: x
  end

  def calc_inverses([], []), do: []

  def calc_inverses([n | ns], [m | ms]) do
    case mod_inv(n, m) do
      nil -> nil
      inv -> [inv | calc_inverses(ns, ms)]
    end
  end

  def chinese_remainder(mods, remainders) do
    # Multiply all the modulus values together
    modpi = List.foldl(mods, 1, fn a, b -> a * b end)

    # Calculate Chinese Remainder Theorum Moduli based on how many times each mod value is divisable by the total.
    crt_mods = Enum.map(mods, fn m -> div(modpi, m) end)

    case calc_inverses(crt_mods, mods) do
      nil ->
        nil

      inv ->
        # Multiply the remainders by the inverses and then multiply by the CRT Moduli
        Enum.zip(
          crt_mods,
          Enum.zip(remainders, inv)
          |> Enum.map(fn {a, b} -> a * b end)
        )
        |> Enum.map(fn {a, b} -> a * b end)
        |> Enum.sum()
        |> mod(modpi)
    end
  end
end
