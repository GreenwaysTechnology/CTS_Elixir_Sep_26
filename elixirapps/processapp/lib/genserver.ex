defmodule CounterServer do
  use GenServer

  def start_link(initial_value \\ 0) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def value do
    GenServer.call(__MODULE__, :value)
  end

  def increment(by \\ 1) do
    GenServer.cast(__MODULE__, {:increment, by})
  end

  def decrement(by \\ 1) do
    GenServer.cast(__MODULE__, {:decrement, by})
  end

  def reset(to \\ 0) do
    GenServer.cast(__MODULE__, {:reset, to})
  end

  def get_and_increment(by \\ 1) do
    GenServer.call(__MODULE__, {:get_and_increment, by})
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  # =================================================
  # Server Callbacks (runs inside the GenServer process)
  # =================================================
  @impl true
  def init(initial_value) do
    # State is just an integer in this example
    {:ok, initial_value}
  end

  # Synchronous calls (caller waits for the reply)
  @impl true
  def handle_call(:value, _from, state) do
    {:reply, state, state}
  end

  # Asynchronous casts (fire-and-forget)
  @impl true
  def handle_cast({:increment, by}, state) do
    {:noreply, state + by}
  end

  def handle_cast({:decrement, by}, state) do
    {:noreply, state - by}
  end

  def handle_cast({:reset, to}, _state) do
    {:noreply, to}
  end

  # Optional: handle unexpected messages
  @impl true
  def handle_info(msg, state) do
    IO.puts("Unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    IO.puts("CounterServer terminating. Reason: #{inspect(reason)}, last state: #{state}")
    :ok
  end
end

