defmodule TodoList do
  use Agent

  def start_link() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

#  Agent.update(__MODULE__, &(&1 ++ [task]))


  def add_task(task) do
    Agent.update(__MODULE__, fn tasks ->
      tasks ++ [task]
    end)
  end

# Agent.get(__MODULE__, &(&1))


  def all() do
    Agent.get(__MODULE__, fn tasks ->
      tasks
    end)
  end

#    Agent.get(__MODULE__, &(length(&1)))

  def count() do
    Agent.get(__MODULE__, fn tasks ->
      length(tasks)
    end)
  end

#    Agent.update(__MODULE__, &List.delete_at(&1, index))

  def remove_task(index) do
    Agent.update(__MODULE__, fn tasks ->
      List.delete_at(tasks, index)
    end)
  end
end
