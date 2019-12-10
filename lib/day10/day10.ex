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
  iex> Advent.Day10.determine_angle(5, 5)
  "R45.0"

  iex> Advent.Day10.determine_angle(2.5, 5)
  "R26.575"

  iex> Advent.Day10.determine_angle(5, 2.5)
  "R63.425"
  """

  def determine_angle(0, y) when y > 0, do: "D"
  def determine_angle(0, _y), do: "U"
  def determine_angle(x, 0) when x > 0, do: "R"
  def determine_angle(_x, 0), do: "L"

  def determine_angle(x, y) do
    angle =
      :math.atan(x / y)
      |> radians_to_degrees()
      |> round_to_x_places(4)

    if x > 0, do: "R#{angle}", else: "L#{angle}"
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
    "0,1" => ["R-45.0", "R", "R", "R45.0"],
    "1,0" => ["L-45.0", "D", "R45.0", "D"],
    "1,1" => ["U", "L", "R", "D"],
    "1,2" => ["U", "L45.0", "U", "R-45.0"],
    "2,1" => ["L45.0", "L", "L", "L-45.0"]
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
            [determine_angle(x2 - x, y2 - y)] ++ other_acc
          else
            other_acc
          end
        end)

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

  iex> Advent.Day10.test0b() |> Advent.Day10.do_work()
  {"3,4", 8}

  iex> Advent.Day10.test1() |> Advent.Day10.do_work()
  {"5,8", 33}

  iex> Advent.Day10.test2() |> Advent.Day10.do_work()
  {"1,2", 35}

  iex> Advent.Day10.test3() |> Advent.Day10.do_work()
  {"6,3", 41}

  iex> Advent.Day10.test4() |> Advent.Day10.do_work()
  {"11,13", 210}
  """

  def do_work(input) do
    input
    |> parse_input()
    |> determine_angles()
    |> get_unique_angles()
    |> Enum.max_by(fn {_key, val} ->
      val
    end)
  end

  def part1 do
    Advent.daily_input(10)
    |> do_work()
  end
end
