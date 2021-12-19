defmodule Aoc202116 do
  def parse(input) do
    input
    |> String.trim()
    |> Base.decode16!()
  end

  def part1(input) do
    {_, versions} =
      input
      |> Packet.decode()

    Enum.sum(versions)
  end

  def part2(input) do
    input
  end

  def run do
    test_input1 = "8A004A801A8002F478" |> parse()
    test_input2 = "620080001611562C8802118E34" |> parse()
    test_input3 = "C0015000016115A2E0802F182340" |> parse()
    test_input4 = "A0016C880162017C3686B18A3D4780" |> parse()

    input =
      Advent.daily_input("2021", "16")
      |> parse()

    IO.puts("Test Answer Part 1 #1: #{inspect(part1(test_input1))}")
    IO.puts("Test Answer Part 1 #2: #{inspect(part1(test_input2))}")
    IO.puts("Test Answer Part 1 #3: #{inspect(part1(test_input3))}")
    IO.puts("Test Answer Part 1 #4: #{inspect(part1(test_input4))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    # IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    # IO.puts("Part 2: #{inspect(part2(input))}")
  end
end

defmodule Packet do
  import Bitwise

  def decode(packet), do: decode_packet(packet, [])

  defp decode_packet(<<ver::3, rest::bits>>, versions),
    do: decode_type(rest, [ver | versions])

  defp decode_type("", versions), do: versions

  defp decode_type(<<4::3, rest::bits>>, versions) do
    {_val, rest} = decode_literal(rest, 0)
    # IO.inspect(val, label: "VAL ====>")
    {rest, versions}
  end

  defp decode_type(<<_operator::3, rest::bits>>, versions), do: decode_operator(rest, versions)

  def decode_operator(<<1::1, packet_count::11, rest::bits>>, versions) do
    Enum.reduce(0..(packet_count - 1), {rest, versions}, fn _, {remaining, versions} ->
      decode_packet(remaining, versions)
    end)
  end

  def decode_operator(
        <<0::1, len::15, packets::size(len)-bits, rest::bits>>,
        versions
      ) do
    new_versions =
      Enum.reduce_while(0..len, {packets, versions}, fn _, {remaining, versions} ->
        decode_packet(remaining, versions)
        |> case do
          {"", versions} -> {:halt, versions}
          val -> {:cont, val}
        end
      end)

    {rest, new_versions}
  end

  defp decode_literal(<<1::1, val::4, rest::bits>>, acc) do
    decode_literal(rest, (acc <<< 4) + val)
  end

  defp decode_literal(<<0::1, val::4, rest::bits>>, acc) do
    {(acc <<< 4) + val, rest}
  end
end
