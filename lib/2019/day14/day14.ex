defmodule Advent.Day14 do
  def parse_input(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [requires_raw, makes] = String.split(row, " => ", trim: true)

      requires =
        String.split(requires_raw, ", ", trim: true)
        |> Enum.map(fn item ->
          [quantity, name] = String.split(item, " ", trim: true)
          {name, String.to_integer(quantity)}
        end)

      [quantity, name] = String.split(makes, " ", trim: true)
      {name, String.to_integer(quantity), requires}
    end)
    |> Enum.reduce(%{}, fn {make, quantity, requires}, acc ->
      Map.put(acc, make, %{quantity: quantity, requires: requires})
    end)
  end

  def current_stock(stock, type), do: Map.get(stock, type, 0)
  def add_stock(stock, type, count), do: Map.put(stock, type, current_stock(stock, type) + count)
  def has_enough_stock?(stock, type, count), do: current_stock(stock, type) >= count

  def remove_stock(stock, type, count),
    do: Map.put(stock, type, current_stock(stock, type) - count)

  def get_requirements(recipes, type, count, stock \\ %{})

  def get_requirements(_, "ORE" = type, count, stock) do
    {add_stock(stock, type, count), count}
  end

  def get_requirements(recipes, request_type, request_count, stock) do
    %{quantity: quantity, requires: requires} = Map.get(recipes, request_type)
    multiplier = Float.ceil(request_count / quantity) |> trunc()

    {final_stock, ore_count} =
      requires
      |> Enum.reduce({stock, 0}, fn {type, needed}, {current_stock, total} ->
        actual_needed = multiplier * needed

        if has_enough_stock?(current_stock, type, actual_needed) do
          {remove_stock(current_stock, type, actual_needed), total}
        else
          {updated_stock, subtotal} =
            get_requirements(
              recipes,
              type,
              actual_needed - current_stock(current_stock, type),
              current_stock
            )

          {updated_stock |> remove_stock(type, actual_needed), subtotal + total}
        end
      end)

    {final_stock |> add_stock(request_type, quantity * multiplier), ore_count}
  end

  def test1 do
    """
    10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL
    """
    |> parse_input()
    |> get_requirements("FUEL", 1)
  end

  def test2 do
    """
    9 ORE => 2 A
    8 ORE => 3 B
    7 ORE => 5 C
    3 A, 4 B => 1 AB
    5 B, 7 C => 1 BC
    4 C, 1 A => 1 CA
    2 AB, 3 BC, 4 CA => 1 FUEL
    """
    |> parse_input()
    |> get_requirements("FUEL", 1)
  end

  def test3(needed \\ 1) do
    """
    157 ORE => 5 NZVS
    165 ORE => 6 DCFZ
    44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
    12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
    179 ORE => 7 PSHF
    177 ORE => 5 HKGWZ
    7 DCFZ, 7 PSHF => 2 XJWVT
    165 ORE => 2 GPVTF
    3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    """
    |> parse_input()
    |> get_requirements("FUEL", needed)
  end

  def test4(needed \\ 1) do
    """
    2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
    17 NVRVD, 3 JNWZP => 8 VPVL
    53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
    22 VJHF, 37 MNCFX => 5 FWMGM
    139 ORE => 4 NVRVD
    144 ORE => 7 JNWZP
    5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
    5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
    145 ORE => 6 MNCFX
    1 NVRVD => 8 CXFTF
    1 VJHF, 6 MNCFX => 4 RFSQX
    176 ORE => 6 VJHF
    """
    |> parse_input()
    |> get_requirements("FUEL", needed)
  end

  def test5(needed \\ 1) do
    """
    171 ORE => 8 CNZTR
    7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
    114 ORE => 4 BHXH
    14 VRPVC => 6 BMBT
    6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
    6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
    15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
    13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
    5 BMBT => 4 WPTQ
    189 ORE => 9 KTJDG
    1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
    12 VRPVC, 27 CNZTR => 2 XDBXC
    15 KTJDG, 12 BHXH => 5 XCVML
    3 BHXH, 2 VRPVC => 7 MZWV
    121 ORE => 7 VRPVC
    7 XCVML => 6 RJRHP
    5 BHXH, 4 VRPVC => 5 LTCX
    """
    |> parse_input()
    |> get_requirements("FUEL", needed)
  end

  def part1 do
    Advent.daily_input(14)
    |> parse_input()
    |> get_requirements("FUEL", 1)
  end

  def find_best(_parsed_input, low, high) when low + 1 == high and not is_nil(high), do: low

  def find_best(parsed_input, low, nil) do
    try_val = 10 * low

    {_stock, ore} =
      Advent.daily_input(14)
      |> parse_input()
      |> get_requirements("FUEL", try_val)

    if ore > 1_000_000_000_000 do
      find_best(parsed_input, low, try_val)
    else
      find_best(parsed_input, try_val, nil)
    end
  end

  def find_best(parsed_input, low, high) do
    try_val = low + div(high - low, 2)

    {_stock, ore} =
      parsed_input
      |> get_requirements("FUEL", try_val)

    if ore > 1_000_000_000_000 do
      find_best(parsed_input, low, try_val)
    else
      find_best(parsed_input, try_val, high)
    end
  end

  def part2 do
    Advent.daily_input(14)
    |> parse_input()
    |> find_best(1_000_000, nil)
  end
end
