defmodule Advent.Day4 do
  defp double_digit?(val) do
    val
    |> String.match?(~r/(\d)\1/)
  end

  defp ordered?(val) do
    val
    |> to_charlist()
    |> Enum.sort()
    |> to_string()
    |> Kernel.==(val)
  end

  defp has_double?(val) do
    val
    |> String.graphemes()
    |> Enum.chunk_by(& &1)
    |> Enum.map(&length/1)
    |> Enum.reduce_while(false, fn x, acc ->
      if x == 2, do: {:halt, true}, else: {:cont, acc}
    end)
  end

  defp matches?(val) do
    ordered?(val) && double_digit?(val)
  end

  defp matches_part2?(val) do
    ordered?(val) && has_double?(val)
  end

  def part1 do
    171_309..643_603 |> Enum.filter(&matches?(to_string(&1))) |> length
  end

  def part2 do
    171_309..643_603 |> Enum.filter(&matches_part2?(to_string(&1))) |> length
  end
end
