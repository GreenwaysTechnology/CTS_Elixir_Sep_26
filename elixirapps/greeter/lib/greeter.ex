# ============================================================
# 1. The GenServer (Counter)
# ============================================================
defmodule Counter do
  use GenServer

  # ---------- Client API ----------
  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def value, do: GenServer.call(__MODULE__, :value)
  def increment(by \\ 1), do: GenServer.cast(__MODULE__, {:increment, by})
  def decrement(by \\ 1), do: GenServer.cast(__MODULE__, {:decrement, by})
  def reset(to \\ 0), do: GenServer.cast(__MODULE__, {:reset, to})

  # ---------- Server Callbacks ----------
  @impl true
  def init(initial_value), do: {:ok, initial_value}

  @impl true
  def handle_call(:value, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast({:increment, by}, state), do: {:noreply, state + by}
  def handle_cast({:decrement, by}, state), do: {:noreply, state - by}
  def handle_cast({:reset, to}, _state), do: {:noreply, to}
end

# ============================================================
# 2. Application Supervisor
# ============================================================
defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Start Counter with initial value 0
      {Counter, 0},

      # Start a Task.Supervisor
      {Task.Supervisor, name: MyApp.TaskSupervisor}
    ]

    # one_for_one = if one child dies, only that child is restarted
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end

# ============================================================
# 3. Application entry point (optional but recommended)
# ============================================================
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    MyApp.Supervisor.start_link()
  end
end
