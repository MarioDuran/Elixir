defmodule UserStore do
  use GenServer

  @table :user_store_cache

  def start_link(initial \\ %{}) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def put(username, age) do
    GenServer.cast(__MODULE__, {:put, username, age})
  end

  def get(username) do
    GenServer.call(__MODULE__, {:get, username})
  end

  def delete(username) do
    GenServer.call(__MODULE__, {:delete, username})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  @impl true
  def init(initial) do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set])
    end

    state = case :ets.lookup(@table, :state) do
      [{:state, saved_state}] -> saved_state
      [] -> initial
    end

    {:ok, state}
  end

  @impl true
  def handle_cast({:put, username, age}, state) do
    new_state = Map.put(state, username, age)
    :ets.insert(@table, {:state, new_state})
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:get, username}, _from, state) do
    {:reply, Map.get(state, username), state}
  end

  @impl true
  def handle_call({:delete, username}, _from, state) do
    new_state = Map.delete(state, username)
    :ets.insert(@table, {:state, new_state})
    {:reply, Map.get(state, username, "No encontrado"), new_state}
  end

  @impl true
  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end

defmodule UserStore.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    children = [
      {UserStore, init_arg}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

UserStore.Supervisor.start_link(%{})

UserStore.put("mario", 30)
UserStore.put("luigi", 25)
IO.inspect(UserStore.all(), label: "Antes de matar")

pid = Process.whereis(UserStore)
Process.exit(pid, :kill)

Process.sleep(100)

IO.inspect(UserStore.all(), label: "Después de reiniciar")
