defmodule Advent.Day13 do
  alias Advent.Opcodes

  defp parse_file do
    Advent.daily_input(13)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def build_tiles([], state), do: state

  def build_tiles([x, y, type | remaining], state) do
    new_state =
      state
      |> Map.put({x, y}, type)

    build_tiles(remaining, new_state)
  end

  def part1 do
    parse_file()
    |> Opcodes.list_to_map()
    |> Opcodes.registers_to_new_state()
    |> Opcodes.parse()
    |> elem(1)
    |> Map.get(:output)
    |> Enum.reverse()
    |> build_tiles(%{})
    |> Enum.filter(fn {_key, value} -> value == 2 end)
    |> Enum.count()
  end

  def determine_move(%{prev_ball: nil}), do: 0

  def determine_move(%{prev_ball: {prev_bx, _prev_by}, ball: {b_x, _b_y}, paddle: {p_x, _p_y}}) do
    if b_x > prev_bx do
      # ball moving right
      if p_x < b_x and p_x < 36 do
        # move right
        1
      else
        # we're to the right, so wait
        0
      end
    else
      # ball moving left
      # we're to the left, so wait
      if p_x > b_x and p_x > 2 do
        # move left
        -1
      else
        0
      end
    end
  end

  def do_work({:halt, _} = state, board), do: {state, board}

  def do_work({_, %{output: output} = state}, board_state) do
    new_board =
      if length(output) == 0 do
        board_state
      else
        state
        |> update_board_state_from_output(board_state)
      end

    new_state =
      state
      |> Map.put(:output, [])
      |> Map.put(:input, [determine_move(new_board)])

    new_state
    |> Opcodes.parse()
    |> do_work(new_board)
  end

  defp tile(0), do: " "
  defp tile(1), do: "#"
  defp tile(2), do: "B"
  defp tile(3), do: "-"
  defp tile(4), do: "o"

  def draw(%{board: state}) do
    Enum.each(0..19, fn y ->
      Enum.map(0..37, fn x ->
        tile(Map.get(state, {x, y}, 0))
      end)
      |> Enum.join("")
      |> IO.puts()
    end)

    IO.puts("Score: #{Map.get(state, {-1, 0}, 0)}")
  end

  def update_board_state(tiles, old_board_state) do
    Enum.reduce(tiles, old_board_state, fn {key, val}, acc ->
      case {key, val} do
        {_, 2} ->
          Map.put(acc, :blocks, Map.get(acc, :blocks, 0) + 1)

        {_, 3} ->
          Map.put(acc, :paddle, key)

        {{x, _}, 4} when x != -1 ->
          Map.put(acc, :prev_ball, Map.get(acc, :ball))
          |> Map.put(:ball, key)

        {{-1, 0}, _} ->
          Map.put(acc, :score, val)

        _ ->
          acc
      end
    end)
    |> Map.put(:board, tiles)
  end

  def update_board_state_from_output(%{output: output}, board_state) do
    output
    |> Enum.reverse()
    |> build_tiles(board_state.board)
    |> update_board_state(board_state |> Map.put(:blocks, 0))
  end

  def part2 do
    {_, program} =
      parse_file()
      |> Opcodes.list_to_map()
      |> Map.put(0, 2)
      |> Opcodes.registers_to_new_state()
      |> Opcodes.parse()

    board_state =
      program
      |> update_board_state_from_output(%{board: %{}})

    updated_program = %{program | output: []}

    {{_status, new_program}, new_board} = do_work({:begin, updated_program}, board_state)

    new_program
    |> update_board_state_from_output(new_board)
    |> draw()

    :ok
  end
end
