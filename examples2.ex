 1..10
|> Task.async_stream(fn n ->
  :timer.sleep(200)
  n * n
end, max_concurrency: 4, ordered: true)
|> Enum.to_list()
|> IO.inspect()
#####
{:ok, agent} = Agent.start_link(fn -> [] end)
IO.inspect(Agent.get(agent, fn list -> list end))
IO.inspect(Agent.get(agent, fn list -> ["eggs" | list] end))
IO.inspect(Agent.stop(agent))

####
defmodule Counter do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__ )
  end

  def value do
    #Agent.get(__MODULE__, & &1)
    Agent.get(__MODULE__, fn x -> x end)
  end
  def increment do
    #Agent.update(__MODULE__, &(&1 + 1))
    Agent.update(__MODULE__, fn x -> x + 1 end)

  end
end

{:ok, _pid} = Counter.start_link(0)

Counter.value()

Counter.increment()
Counter.increment()

Counter.value()


###


defmodule Counter do
  use GenServer

  # Client API

  def start_link(initial \\ 0) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def value do
    GenServer.call(__MODULE__, :value)
  end

  def increment do
    GenServer.cast(__MODULE__, :increment)
  end

  def add(n) when is_integer(n) do
    GenServer.cast(__MODULE__, {:add, n})
  end

  # Server callbacks

  @impl true
  def init(initial) do
    {:ok, initial}
  end

  @impl true
  def handle_call(:value, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:increment, state) do
    {:noreply, state + 1}
  end

  @impl true
  def handle_cast({:add, n}, state) do
    {:noreply, state + n}
  end
end

Counter.start_link(10)

IO.inspect(Counter.value())

Counter.increment()

IO.inspect(Counter.value())

Counter.add(5)

IO.inspect(Counter.value())

