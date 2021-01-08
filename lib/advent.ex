defmodule Advent do
  @moduledoc """
  Documentation for Advent.
  """

  def daily_input(day_num) do
    File.read!("lib/2019/day#{day_num}/day#{day_num}.input")
  end

  def daily_input(year, day_num) do
    File.read!("priv/input/#{year}#{day_num}.input")
  end

  def output(fun, label \\ "Result:") do
    {duration, result} = :timer.tc(fun)

    if is_binary(result),
      do: IO.puts("#{label} #{result}"),
      else: IO.inspect(result, label: label)

    IO.puts("#{div(duration, 1000)} ms\n")
  end

  @spec start_queue_agent :: pid
  def start_queue_agent do
    {:ok, pid} = Agent.start_link(fn -> :queue.new() end)
    pid
  end

  @spec enqueue(pid, term()) :: :ok
  def enqueue(queue_agent, value) do
    :ok = Agent.update(queue_agent, fn queue -> :queue.in(value, queue) end)
  end

  @spec queue_depth(pid) :: integer()
  def queue_depth(queue_agent) do
    Agent.get(queue_agent, fn queue -> :queue.len(queue) end)
  end

  @spec clear_queue(pid) :: :ok
  def clear_queue(queue_agent) do
    :ok = Agent.update(queue_agent, fn _queue -> :queue.new() end)
  end

  @spec dequeue(pid) :: :empty | term()
  def dequeue(queue_agent) do
    {raw_value, new_queue} =
      Agent.get(queue_agent, fn queue ->
        :queue.out(queue)
      end)

    Agent.update(queue_agent, fn _old_queue -> new_queue end)

    raw_value
    |> case do
      {:value, value} -> value
      _ -> raw_value
    end
  end
end

defmodule Advent.WeightedQueue do
  use Agent

  def start_link() do
    Agent.start_link(fn -> Heap.new() end, name: __MODULE__)
  end

  def clear() do
    Agent.update(__MODULE__, fn _stack -> Heap.new() end)
  end

  def enqueue(value) do
    :ok = Agent.update(__MODULE__, fn heap -> Heap.push(heap, value) end)
  end

  def dequeue() do
    Agent.get(__MODULE__, fn heap -> Heap.root(heap) end)
    |> case do
      nil ->
        :empty

      val ->
        Agent.update(__MODULE__, fn heap -> Heap.pop(heap) end)

        val
    end
  end

  def depth() do
    Agent.get(__MODULE__, fn heap -> Heap.size(heap) end)
  end
end

defmodule Advent.Stack do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def add(value) do
    :ok = Agent.update(__MODULE__, fn stack -> [value | stack] end)
  end

  def depth() do
    Agent.get(__MODULE__, fn stack -> length(stack) end)
  end

  defp pop_fn([]), do: :empty
  defp pop_fn([val | _rest]), do: val
  defp pop_update_fn([]), do: []
  defp pop_update_fn([_val | rest]), do: rest

  def pop() do
    value = Agent.get(__MODULE__, &pop_fn/1)
    Agent.update(__MODULE__, &pop_update_fn/1)

    value
  end
end
