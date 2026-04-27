defmodule Counter do
  use GenServer

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

defmodule Counter.Supervisor do
  use Supervisor

  def start_link(initial_value) do
    Supervisor.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  @impl true
  def init(initial_value) do
    children = [
      {Counter, initial_value}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

Counter.Supervisor.start_link(10)

Counter.increment()
Counter.add(5)
IO.inspect(Counter.value(), label: "Valor antes de morir")

pid = Process.whereis(Counter)
Process.exit(pid, :kill)

Process.sleep(10)

IO.inspect(Counter.value(), label: "Valor después del reinicio")
