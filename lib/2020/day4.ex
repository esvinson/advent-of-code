defmodule Aoc202004 do
  defp test_input,
    do: """
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in
    """

  defp test_input2,
    do: """
    eyr:1972 cid:100
    hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

    iyr:2019
    hcl:#602927 eyr:1967 hgt:170cm
    ecl:grn pid:012533040 byr:1946

    hcl:dab227 iyr:2012
    ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

    hgt:59cm ecl:zzz
    eyr:2038 hcl:74454a iyr:2023
    pid:3556412378 byr:2007

    pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
    hcl:#623a2f

    eyr:2029 ecl:blu cid:129 byr:1989
    iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

    hcl:#888785
    hgt:164cm byr:2001 iyr:2015 cid:88
    pid:545766238 ecl:hzl
    eyr:2022

    iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    """

  defp output_to_list_of_maps(input) do
    input
    |> to_string()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(~r/[\n ]/, trim: true)
      |> Enum.reduce(%{}, fn item, acc ->
        [field, value] = String.split(item, ":", trim: true)
        if field != "cid", do: Map.put(acc, String.to_atom(field), value), else: acc
      end)
    end)
  end

  defp is_valid?(%{byr: _, iyr: _, eyr: _, hgt: _, hcl: _, ecl: _, pid: _}), do: true
  defp is_valid?(_map), do: false

  defp is_data_valid?(%{
         byr: birthyear,
         iyr: issued,
         eyr: expires,
         hgt: height,
         hcl: haircolor,
         ecl: eyecolor,
         pid: id
       }) do
    birthyear_int = String.to_integer(birthyear)
    issued_int = String.to_integer(issued)
    expires_int = String.to_integer(expires)

    height_invalid? =
      case height |> String.reverse() |> String.to_charlist() do
        ~c"mc" ++ cm_height_rev ->
          cm_height =
            cm_height_rev
            |> Enum.reverse()
            |> to_string()
            |> String.to_integer()

          cm_height < 150 || cm_height > 193

        ~c"ni" ++ inch_height_rev ->
          inch_height =
            inch_height_rev
            |> Enum.reverse()
            |> to_string()
            |> String.to_integer()

          inch_height < 59 || inch_height > 76

        _ ->
          true
      end

    cond do
      !String.match?(id, ~r/^[\d]{9}$/) ->
        false

      !String.match?(birthyear, ~r/^[\d]{4}$/) || birthyear_int > 2002 || birthyear_int < 1920 ->
        false

      !String.match?(issued, ~r/^[\d]{4}$/) || issued_int > 2020 || issued_int < 2010 ->
        false

      !String.match?(expires, ~r/^[\d]{4}$/) || expires_int > 2030 || expires_int < 2020 ->
        false

      height_invalid? ->
        false

      !String.match?(haircolor, ~r/^#[0-9a-f]{6}$/) ->
        false

      !String.match?(eyecolor, ~r/^(amb|blu|brn|gry|grn|hzl|oth)$/) ->
        false

      true ->
        true
    end
    |> case do
      false ->
        false

      true ->
        true
    end
  end

  def part1(list) do
    list
    |> Enum.filter(&is_valid?(&1))
    |> Enum.count()
  end

  def part2(list) do
    list
    |> Enum.filter(&is_valid?(&1))
    |> Enum.filter(&is_data_valid?(&1))
    |> Enum.count()
  end

  def run do
    test_list = test_input() |> output_to_list_of_maps()
    test_list2 = test_input2() |> output_to_list_of_maps()
    list = Advent.daily_input("2020", "04") |> output_to_list_of_maps()
    testresult1 = part1(test_list)
    IO.puts("Solution to Part 1 Test (should be 2): #{testresult1}")

    result1 = part1(list)
    IO.puts("Solution to Part 1: #{result1}")

    testresult2 = part2(test_list2)
    IO.puts("Solution to Part 2 Test (should be 4): #{testresult2}")

    result2 = part2(list)
    IO.puts("Solution to Part 2: #{result2}")
  end
end
