defmodule Aoc202207 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  def safe_path(""), do: ""
  def safe_path("/" <> path), do: "/#{path}"
  def safe_path(path), do: "/#{path}"

  def run([], _path, parents, output) do
    parents
    |> Enum.sort(:desc)
    |> Enum.reduce(output, fn {child, parent}, new_output ->
      add_value = Map.get(new_output, child, 0)

      Map.update(new_output, parent, add_value, fn existing_value ->
        existing_value + add_value
      end)
    end)
  end

  def run(["$ ls" | rest], path, parents, output), do: run(rest, path, parents, output)

  def run(["$ cd .." | rest], current_path, parents, output) do
    new_path =
      current_path
      |> String.split("/", trim: true)
      |> Enum.drop(-1)
      |> Enum.join("/")
      |> safe_path()

    run(rest, new_path, parents, output)
  end

  def run(["$ cd /" | rest], _current_path, parents, output) do
    run(rest, "", parents, output)
  end

  def run(["$ cd " <> path | rest], current_path, parents, output) do
    new_path =
      (current_path <> "/" <> path)
      |> safe_path()

    run(rest, new_path, parents, output)
  end

  def run(["dir " <> subdir | rest], current_path, parents, output) do
    subdir_path =
      (current_path <> "/" <> subdir)
      |> safe_path()

    new_parents = Map.put(parents, subdir_path, current_path)

    run(rest, current_path, new_parents, output)
  end

  def run([ls_data | rest], current_path, parents, output) do
    [size_str, _path] = String.split(ls_data, " ", trim: true)
    size = String.to_integer(size_str)

    new_output =
      Map.update(output, current_path, size, fn existing_value -> existing_value + size end)

    run(rest, current_path, parents, new_output)
  end

  def part1(start) do
    run(start, "", %{}, %{})
    |> Enum.map(fn {_, val} -> val end)
    |> Enum.reject(fn val -> val > 100_000 end)
    |> Enum.sum()
  end

  def part2(start) do
    dir_sizes = run(start, "", %{}, %{})
    total_used = Map.get(dir_sizes, "")

    available = 70_000_000 - total_used
    needed = 30_000_000 - available

    dir_sizes
    |> Enum.map(fn {_, val} -> val end)
    |> Enum.sort()
    |> Enum.reject(fn x -> x < needed end)
    |> List.first()
  end

  def run do
    test_input =
      """
      $ cd /
      $ ls
      dir a
      14848514 b.txt
      8504156 c.dat
      dir d
      $ cd a
      $ ls
      dir e
      29116 f
      2557 g
      62596 h.lst
      $ cd e
      $ ls
      584 i
      $ cd ..
      $ cd ..
      $ cd d
      $ ls
      4060174 j
      8033020 d.log
      5626152 d.ext
      7214296 k
      """
      |> parse()

    input = Advent.daily_input("2022", "07") |> parse()

    IO.puts("Test Answer Part 1: #{inspect(part1(test_input))}")
    IO.puts("Part 1: #{inspect(part1(input))}")
    IO.puts("Test Answer Part 2: #{inspect(part2(test_input))}")
    IO.puts("Part 2: #{inspect(part2(input))}")
  end
end
