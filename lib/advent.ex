defmodule Advent do
  @moduledoc """
  Documentation for Advent.
  """

  def daily_input(day_num) do
    File.read!("lib/day#{day_num}/day#{day_num}.input")
  end
end
