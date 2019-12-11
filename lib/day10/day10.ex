defmodule Advent.Day10 do
  defp round_to_x_places(value, x) do
    places = x * 10

    value
    |> Kernel.*(places)
    |> round()
    |> Kernel./(places)
  end

  defp radians_to_degrees(radians) do
    radians / (:math.pi() / 180)
  end

  @doc """
  # Example
  iex> Advent.Day10.determine_angle(0, 5, 0, 5)
  135.0

  iex> Advent.Day10.determine_angle(0, 5, 5, 0)
  45.0

  iex> Advent.Day10.determine_angle(5, 0, 5, 0)
  315.0

  iex> Advent.Day10.determine_angle(8, 11, 2, 13)
  164.75

  iex> Advent.Day10.determine_angle(11, 8, 13, 2)
  344.75
  """

  def determine_angle(x1, x2, y1, y2) when x2 == x1 and y2 < y1, do: 0.0
  def determine_angle(x1, x2, y1, y2) when x2 == x1 and y2 > y1, do: 180.0
  def determine_angle(x1, x2, y1, y2) when y2 == y1 and x2 > x1, do: 90.0
  def determine_angle(x1, x2, y1, y2) when y2 == y1 and x2 < x1, do: 270.0

  def determine_angle(x1, x2, y1, y2) when x2 > x1 and y2 > y1,
    do: 180 - determine_angle(x2 - x1, y2 - y1)

  def determine_angle(x1, x2, y1, y2) when x2 > x1 and y2 < y1,
    do: determine_angle(x2 - x1, y2 - y1)

  def determine_angle(x1, x2, y1, y2) when x2 < x1 and y2 > y1,
    do: 180 + determine_angle(x2 - x1, y2 - y1)

  def determine_angle(x1, x2, y1, y2) when x2 < x1 and y2 < y1,
    do: 360 - determine_angle(x2 - x1, y2 - y1)

  def determine_angle(x, y) do
    :math.atan(x / y)
    |> radians_to_degrees()
    |> round_to_x_places(4)
    |> abs()
  end

  def test0 do
    """
    .#.
    ###
    .#.
    """
  end

  def test0b do
    """
    .#..#
    .....
    #####
    ....#
    ...##
    """
  end

  def test1 do
    """
    ......#.#.
    #..#.#....
    ..#######.
    .#.#.###..
    .#..#.....
    ..#....#.#
    #..#....#.
    .##.#..###
    ##...#..#.
    .#....####
    """
  end

  def test2 do
    """
    #.#...#.#.
    .###....#.
    .#....#...
    ##.#.#.#.#
    ....#.#.#.
    .##..###.#
    ..#...##..
    ..##....##
    ......#...
    .####.###.
    """
  end

  def test3 do
    """
    .#..#..###
    ####.###.#
    ....###.#.
    ..###.##.#
    ##.##.#.#.
    ....###..#
    ..#.#..#.#
    #..#.#.###
    .##...##.#
    .....#.#..
    """
  end

  def test4 do
    """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """
  end

  def testpart2 do
    # 8,3
    """
    .#....#####...#..
    ##...##.#####..##
    ##...#...#.#####.
    ..#.....X...###..
    ..#.#.....#....##
    """
  end

  defp convert_to_list_of_points(map) do
    map
    # |> Enum.to_list()
    |> Enum.reduce([], fn {y, row}, acc ->
      row
      |> Enum.reduce([], fn x, row_acc ->
        [{x, y}] ++ row_acc
      end)
      |> Kernel.++(acc)
    end)
  end

  @doc """
  # Example

  iex> Advent.Day10.test0 |> Advent.Day10.parse_input()
  [{1, 2}, {2, 1}, {1, 1}, {0, 1}, {1, 0}]
  """

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_key}, acc ->
      transformed_row =
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce([], fn {col, col_key}, row_acc ->
          if col == "#" do
            row_acc ++ [col_key]
          else
            row_acc
          end
        end)

      Map.put(acc, row_key, transformed_row)
    end)
    |> convert_to_list_of_points()
  end

  @doc """
  # Example

  iex> [{1, 2}, {2, 1}, {1, 1}, {0, 1}, {1, 0}] |> Advent.Day10.determine_angles()
  %{
    "0,1" => [45.0, 90.0, 90.0, 135.0],
    "1,0" => [225.0, 180.0, 135.0, 180.0],
    "1,1" => [0.0, 270.0, 90.0, 180.0],
    "1,2" => [0.0, 315.0, 0.0, 45.0],
    "2,1" => [315.0, 270.0, 270.0, 225.0]
  }
  """

  def determine_angles(points) do
    points
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      key = "#{x},#{y}"

      angles =
        points
        |> Enum.reduce([], fn {x2, y2}, other_acc ->
          if x2 != x || y2 != y do
            [determine_angle(x, x2, y, y2)] ++ other_acc
          else
            other_acc
          end
        end)

      Map.put(acc, key, angles)
    end)
  end

  def determine_angles_part2(points) do
    points
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      key = "#{x},#{y}"

      angles =
        points
        |> Enum.reduce([], fn {x2, y2}, other_acc ->
          if x2 != x || y2 != y do
            distance = :math.sqrt(:math.pow(x2 - x, 2) + :math.pow(y2 - y, 2))
            angle = determine_angle(x, x2, y, y2)
            [{x2, y2, distance, angle}] ++ other_acc
          else
            other_acc
          end
        end)
        |> Enum.sort_by(fn {_, _, distance, angle} -> {angle, distance} end)

      Map.put(acc, key, angles)
    end)
  end

  def get_unique_angles(points_with_angles) do
    points_with_angles
    |> Enum.reduce([], fn {key, row}, acc ->
      val =
        row
        |> Enum.sort()
        |> Enum.dedup()
        |> Enum.count()

      [{key, val}] ++ acc
    end)
  end

  @doc """
  # Example

  iex> Advent.Day10.test0b() |> Advent.Day10.build_angles() |> Advent.Day10.part1_transform()
  {"3,4", 8}

  iex> Advent.Day10.test1() |> Advent.Day10.build_angles() |> Advent.Day10.part1_transform()
  {"5,8", 33}

  iex> Advent.Day10.test2() |> Advent.Day10.build_angles() |> Advent.Day10.part1_transform()
  {"1,2", 35}

  iex> Advent.Day10.test3() |> Advent.Day10.build_angles() |> Advent.Day10.part1_transform()
  {"6,3", 41}

  iex> Advent.Day10.test4() |> Advent.Day10.build_angles() |> Advent.Day10.part1_transform()
  {"11,13", 210}

  """
  def part1_transform(angles) do
    angles
    |> get_unique_angles()
    |> Enum.max_by(fn {_key, val} ->
      val
    end)
  end

  def part2_transform(angles, laser_xy) do
    sets =
      Map.get(angles, laser_xy)
      |> Enum.group_by(fn {_, _, _, angle} -> angle end)

    keys = sets |> Map.keys() |> Enum.sort()

    {keys, sets}
  end

  def build_angles(input) do
    input
    |> parse_input()
    |> determine_angles()
  end

  def build_angles_part2(input) do
    input
    |> parse_input()
    |> determine_angles_part2()
  end

  @doc """
  # Example
  iex> Advent.Day10.test4() |> Advent.Day10.build_angles_part2() |> Advent.Day10.part2_transform("11,13") |> Advent.Day10.process_sets(0, []) |> Advent.Day10.get_answer(200)
  802
  """

  def process_sets({keys, sets}, offset, output) do
    sets_left = Enum.count(Map.keys(sets))

    if sets_left == 0 do
      output |> Enum.reverse()
    else
      num = Enum.count(keys)
      new_offset = rem(offset + 1, num)
      angle = Enum.at(keys, offset)

      {new_set, new_output} =
        Map.get(sets, angle, [])
        |> case do
          [] -> {[], output}
          [point | remaining] -> {remaining, [point] ++ output}
        end

      new_sets =
        if Enum.count(new_set) != 0 do
          Map.put(sets, angle, new_set)
        else
          Map.delete(sets, angle)
        end

      process_sets({keys, new_sets}, new_offset, new_output)
    end
  end

  def part1 do
    Advent.daily_input(10)
    |> build_angles()
    |> part1_transform()
  end

  def get_answer(sets, offset) do
    {x, y, _, _} = Enum.at(sets, offset - 1)
    x * 100 + y
  end

  def part2 do
    {best_xy, _} =
      Advent.daily_input(10)
      |> build_angles()
      |> part1_transform()

    Advent.daily_input(10)
    |> build_angles_part2()
    |> part2_transform(best_xy)
    |> process_sets(0, [])
    |> get_answer(200)
  end
end
