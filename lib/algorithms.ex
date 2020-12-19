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

  @operators ["+", "*", "/", "-"]

  def to_rpn_np([], {output, []}), do: output

  def to_rpn_np([], {output, [operator | operators]}),
    do: to_rpn_np([], {[operator | output], operators})

  def to_rpn_np([item | rest], {output, operators}) when is_integer(item),
    do: to_rpn_np(rest, {[item | output], operators})

  def to_rpn_np([item | rest], {output, []}) when item in @operators,
    do: to_rpn_np(rest, {output, [item]})

  def to_rpn_np([item | rest], {output, [operator | operators]})
      when item in @operators and operator in @operators,
      do: to_rpn_np([item | rest], {[operator | output], operators})

  def to_rpn_np([item | rest], {output, operators}) when item in @operators,
    do: to_rpn_np(rest, {output, [item | operators]})

  def to_rpn_np([item | rest], {output, operators}) when item == "(",
    do: to_rpn_np(rest, {output, [item | operators]})

  def to_rpn_np([item | _rest] = remaining, {output, [operator | operators]})
      when item == ")" and operator != "(" do
    to_rpn_np(remaining, {[operator | output], operators})
  end

  def to_rpn_np([item | rest], {output, [operator | operators]})
      when item == ")" and operator == "(" do
    to_rpn_np(rest, {output, operators})
  end

  # Shunting Yard Algorithm
  def infix_to_rpn_no_precedence(infix) do
    to_rpn_np(infix, {[], []}) |> Enum.reverse()
  end

  def rpn_calc([], [stack]), do: stack

  def rpn_calc([left | equation], stack) when is_integer(left),
    do: rpn_calc(equation, [left | stack])

  def rpn_calc(["+" | equation], [left, right | stack]),
    do: rpn_calc(equation, [left + right | stack])

  def rpn_calc(["-" | equation], [left, right | stack]),
    do: rpn_calc(equation, [left - right | stack])

  def rpn_calc(["*" | equation], [left, right | stack]),
    do: rpn_calc(equation, [left * right | stack])

  def rpn_calc(["/" | equation], [left, right | stack]),
    do: rpn_calc(equation, [left / right | stack])

  # Reverse Polish Notation Calculator
  def rpn_calc(equation) do
    rpn_calc(equation, [])
  end
end
