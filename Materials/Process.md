1. spawn
The most basic way to create a new process.
Elixirpid = spawn(fn -> 
  IO.puts("Hello from process #{inspect(self())}")
end)

Extremely lightweight (thousands or millions can run).
Isolated memory — no shared state.
Returns a PID (process identifier).
The process dies when the function finishes (or crashes).

defmodule App.Process do
  def start_process do
    pid =
      spawn(fn ->
        IO.puts("Hello from process #{inspect(self())}")
      end)

    IO.inspect(pid)
  end

end



There are also spawn_link/1 and spawn_monitor/1 for linking/monitoring.

spawn_link/1 and spawn_monitor/1 (also available as /3 variants) are the two main ways to start a process in Elixir while establishing a relationship with the caller.
spawn_link/1 (and /3)

Atomically spawns a process and links it to the calling process.
Returns just the PID.
The link is bidirectional (symmetric).
When one process exits (for any reason other than :normal by default), it sends an exit signal to the other. Unless the receiver is trapping exits (Process.flag(:trap_exit, true)), the receiver also exits with the same reason.
This is the classic “suicide pact” / failure-propagation mechanism.


spawn_monitor/1 (and /3)

Atomically spawns a process and monitors it.
Returns a tuple {pid, monitor_ref}.
The monitor is unidirectional (asymmetric): only the caller watches the new process.
When the monitored process exits, the caller receives a regular message of the form:Elixir{:DOWN, ref, :process, pid, reason}
The caller does not exit. It just gets notified.

Elixir{pid, ref} = spawn_monitor(fn -> raise "boom" end)

receive do
  {:DOWN, ^ref, :process, ^pid, reason} ->
    IO.inspect(reason)   # the exit reason
end

Aspect,spawn_link,spawn_monitor
Relationship,Bidirectional link,Unidirectional monitor
Failure behaviour,Propagates exit (can kill caller),Sends :DOWN message only
Return value,pid,"{pid, reference}"
Trap exits needed?,"Yes, if you want to survive",No
Typical use,"Tightly coupled processes, supervisors",Observing / managing other processes without dying with them

When to use which

Use spawn_link when the processes truly depend on each other (if one dies, the other should also die, or you want to trap the exit and react).

Use spawn_monitor when you only need to be informed that another process has terminated, without risking your own process dying.


Expected output (simplified)
text=== spawn_link example ===
Linked process started (pid: #PID<0.xxx.0>)
Spawned linked process: #PID<0.xxx.0>
Received EXIT from #PID<0.xxx.0>
Reason: {%RuntimeError{message: "boom from linked process"}, [...]}
Current process still alive

=== spawn_monitor example ===
Monitored process started (pid: #PID<0.yyy.0>)
Spawned monitored process: #PID<0.yyy.0>
Monitor reference: #Reference<...>
Received DOWN from #PID<0.yyy.0>
Reason: {%RuntimeError{message: "boom from monitored process"}, [...]}
Current process still alive
Key points shown in the module:

spawn_link → you get an {:EXIT, pid, reason} message (only because we trapped exits).
spawn_monitor → you get a {:DOWN, ref, :process, pid, reason} message and the caller never dies.
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

2. send and receive

Processes communicate only by message passing.

Elixir# Sender
send(pid, {:hello, "world"})

# Receiver
receive do
  {:hello, msg} -> IO.puts("Got: #{msg}")
  other -> IO.puts("Unexpected: #{inspect(other)}")
after
  5_000 -> IO.puts("Timeout")
end

Messages are copied and go into the process mailbox.
receive is selective and pattern-matches.
Non-blocking for the sender; the receiver waits (or times out).
&&&&&&&&&&&&&&&&&

Tasks:
	Tasks build on top of the spawn functions to provide better error reports and introspection

Higher-level abstraction for one-off asynchronous work.

Elixir# Fire and forget
Task.start(fn -> do_work() end)

# Await the result
task = Task.async(fn -> expensive_calculation() end)
result = Task.await(task, 10_000)

# Or with a supervisor
Task.Supervisor.start_child(MyApp.TaskSupervisor, fn -> ... end)

Common uses:
Parallel map (Task.async_stream)
Background jobs
Timeouts and cancellation support

Common patterns:

Task.async/1 + Task.await/2
Task.async_stream/3 for concurrent mapping over a collection
Supervised tasks via Task.Supervisor


defmodule TaskExamples do
  @moduledoc """
  Full working examples of the three main Task APIs:

  1. Fire-and-forget  → Task.start/1
  2. Await a result   → Task.async/1 + Task.await/2
  3. Supervised task  → Task.Supervisor.start_child/2
  """

  # -------------------------------------------------
  # 1. Fire and forget – Task.start/1
  # -------------------------------------------------
  def fire_and_forget do
    IO.puts("\n=== 1. Fire and forget (Task.start) ===")

    {:ok, pid} =
      Task.start(fn ->
        IO.puts("  [background] Starting work in #{inspect(self())}")
        :timer.sleep(800)
        IO.puts("  [background] Work finished!")
      end)

    IO.puts("Spawned fire-and-forget task: #{inspect(pid)}")
    IO.puts("Main process continues immediately...")
    :timer.sleep(1200)   # just so we can see the background message
    IO.puts("Main process finished.\n")
  end

  # -------------------------------------------------
  # 2. Await the result – Task.async + Task.await
  # -------------------------------------------------
  def await_result do
    IO.puts("=== 2. Await the result (Task.async + Task.await) ===")

    task =
      Task.async(fn ->
        IO.puts("  [async] Starting expensive calculation in #{inspect(self())}")
        :timer.sleep(1000)
        result = 42 * 42
        IO.puts("  [async] Calculation done → #{result}")
        result
      end)

    IO.puts("Task started, now waiting for the result...")
    result = Task.await(task, 5_000)   # timeout 5 seconds
    IO.puts("Got the result: #{result}\n")
  end

  # -------------------------------------------------
  # 3. Supervised task – Task.Supervisor.start_child
  # -------------------------------------------------
  def supervised_task do
    IO.puts("=== 3. Supervised task (Task.Supervisor) ===")

    # Start a temporary Task.Supervisor for this demo
    {:ok, supervisor} = Task.Supervisor.start_link(name: :demo_task_sup)

    # Start a supervised task (linked to the supervisor)
    {:ok, pid} =
      Task.Supervisor.start_child(supervisor, fn ->
        IO.puts("  [supervised] Task started in #{inspect(self())}")
        :timer.sleep(700)
        IO.puts("  [supervised] Task completed successfully")
      end)

    IO.puts("Supervised task PID: #{inspect(pid)}")
    :timer.sleep(1000)

    # You can also start a task that returns a value and await it
    task =
      Task.Supervisor.async(supervisor, fn ->
        :timer.sleep(400)
        "hello from supervised async"
      end)

    result = Task.await(task)
    IO.puts("Supervised async result: #{result}")

    # Clean up the temporary supervisor
    Supervisor.stop(supervisor)
    IO.puts("Demo finished.\n")
  end

  # -------------------------------------------------
  # Run all examples
  # -------------------------------------------------
  def run_all do
    fire_and_forget()
    await_result()
    supervised_task()
  end
end

Expected output:
=== 1. Fire and forget (Task.start) ===
Spawned fire-and-forget task: #PID<0.xxx.0>
Main process continues immediately...
  [background] Starting work in #PID<0.xxx.0>
  [background] Work finished!
Main process finished.

=== 2. Await the result (Task.async + Task.await) ===
  [async] Starting expensive calculation in #PID<0.yyy.0>
Task started, now waiting for the result...
  [async] Calculation done → 1764
Got the result: 1764

=== 3. Supervised task (Task.Supervisor) ===
  [supervised] Task started in #PID<0.zzz.0>
Supervised task PID: #PID<0.zzz.0>
  [supervised] Task completed successfully
Supervised async result: hello from supervised async
Demo finished.

Here’s a complete, ready-to-run module that demonstrates all three common `Task` APIs:

```elixir
defmodule TaskExamples do
  @moduledoc """
  Full working examples of the three main Task APIs:

  1. Fire-and-forget  → Task.start/1
  2. Await a result   → Task.async/1 + Task.await/2
  3. Supervised task  → Task.Supervisor.start_child/2
  """

  # -------------------------------------------------
  # 1. Fire and forget – Task.start/1
  # -------------------------------------------------
  def fire_and_forget do
    IO.puts("\n=== 1. Fire and forget (Task.start) ===")

    {:ok, pid} =
      Task.start(fn ->
        IO.puts("  [background] Starting work in #{inspect(self())}")
        :timer.sleep(800)
        IO.puts("  [background] Work finished!")
      end)

    IO.puts("Spawned fire-and-forget task: #{inspect(pid)}")
    IO.puts("Main process continues immediately...")
    :timer.sleep(1200)   # just so we can see the background message
    IO.puts("Main process finished.\n")
  end

  # -------------------------------------------------
  # 2. Await the result – Task.async + Task.await
  # -------------------------------------------------
  def await_result do
    IO.puts("=== 2. Await the result (Task.async + Task.await) ===")

    task =
      Task.async(fn ->
        IO.puts("  [async] Starting expensive calculation in #{inspect(self())}")
        :timer.sleep(1000)
        result = 42 * 42
        IO.puts("  [async] Calculation done → #{result}")
        result
      end)

    IO.puts("Task started, now waiting for the result...")
    result = Task.await(task, 5_000)   # timeout 5 seconds
    IO.puts("Got the result: #{result}\n")
  end

  # -------------------------------------------------
  # 3. Supervised task – Task.Supervisor.start_child
  # -------------------------------------------------
  def supervised_task do
    IO.puts("=== 3. Supervised task (Task.Supervisor) ===")

    # Start a temporary Task.Supervisor for this demo
    {:ok, supervisor} = Task.Supervisor.start_link(name: :demo_task_sup)

    # Start a supervised task (linked to the supervisor)
    {:ok, pid} =
      Task.Supervisor.start_child(supervisor, fn ->
        IO.puts("  [supervised] Task started in #{inspect(self())}")
        :timer.sleep(700)
        IO.puts("  [supervised] Task completed successfully")
      end)

    IO.puts("Supervised task PID: #{inspect(pid)}")
    :timer.sleep(1000)

    # You can also start a task that returns a value and await it
    task =
      Task.Supervisor.async(supervisor, fn ->
        :timer.sleep(400)
        "hello from supervised async"
      end)

    result = Task.await(task)
    IO.puts("Supervised async result: #{result}")

    # Clean up the temporary supervisor
    Supervisor.stop(supervisor)
    IO.puts("Demo finished.\n")
  end

  # -------------------------------------------------
  # Run all examples
  # -------------------------------------------------
  def run_all do
    fire_and_forget()
    await_result()
    supervised_task()
  end
end
```

### How to run it

```elixir
# In iex
c("task_examples.ex")   # or just paste the module
TaskExamples.run_all()
```

### Expected output (approximate)

```
=== 1. Fire and forget (Task.start) ===
Spawned fire-and-forget task: #PID<0.xxx.0>
Main process continues immediately...
  [background] Starting work in #PID<0.xxx.0>
  [background] Work finished!
Main process finished.

=== 2. Await the result (Task.async + Task.await) ===
  [async] Starting expensive calculation in #PID<0.yyy.0>
Task started, now waiting for the result...
  [async] Calculation done → 1764
Got the result: 1764

=== 3. Supervised task (Task.Supervisor) ===
  [supervised] Task started in #PID<0.zzz.0>
Supervised task PID: #PID<0.zzz.0>
  [supervised] Task completed successfully
Supervised async result: hello from supervised async
Demo finished.
```

### Quick reference

| API | Purpose | Returns | Linked? | Common use |
|-----|---------|---------|---------|------------|
| `Task.start/1` | Fire-and-forget | `{:ok, pid}` | No | Side-effects only |
| `Task.async/1` + `Task.await/2` | Get a result | `%Task{}` → value | Yes (to caller) | One-off calculations |
| `Task.Supervisor.start_child/2` | Supervised fire-and-forget | `{:ok, pid}` | Yes (to supervisor) | Background jobs under supervision |
| `Task.Supervisor.async/2` | Supervised + awaitable | `%Task{}` | Yes (to supervisor) | 


4. State
Processes hold state in their mailbox / recursive loop.
Classic pattern (before OTP abstractions):

def loop(state) do
  receive do
    {:get, from} ->
      send(from, state)
      loop(state)
    {:put, new_state} ->
      loop(new_state)
  end
end

OTP provides better tools: Agent, GenServer, etc.

5. Agent
Simple key-value / state holder. Best for very simple shared state.

Internally a GenServer
Prefer GenServer when you need more control (timeouts, casting, complex logic)

defmodule Counter do
  @moduledoc """
  A simple stateful counter implemented with Agent.
  """

  # -------------------------------------------------
  # Start the Agent (holds the state)
  # -------------------------------------------------
  def start_link(initial_value \\ 0) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  # -------------------------------------------------
  # Read the current state
  # -------------------------------------------------
  def value do
    Agent.get(__MODULE__, fn state -> state end)
  end

  # -------------------------------------------------
  # Update the state (increment)
  # -------------------------------------------------
  def increment(by \\ 1) do
    Agent.update(__MODULE__, fn state -> state + by end)
  end

  # -------------------------------------------------
  # Update the state (decrement)
  # -------------------------------------------------
  def decrement(by \\ 1) do
    Agent.update(__MODULE__, fn state -> state - by end)
  end

  # -------------------------------------------------
  # Reset the state
  # -------------------------------------------------
  def reset(to \\ 0) do
    Agent.update(__MODULE__, fn _state -> to end)
  end

  # -------------------------------------------------
  # Get and update in one step (returns the old value)
  # -------------------------------------------------
  def get_and_increment(by \\ 1) do
    Agent.get_and_update(__MODULE__, fn state ->
      {state, state + by}   # {return_value, new_state}
    end)
  end
end

How to use it in iex

# 1. Start the Agent with an initial value
{:ok, _pid} = Counter.start_link(10)

# 2. Read the current state
Counter.value()
# => 10

# 3. Increment
Counter.increment()
Counter.value()
# => 11

Counter.increment(5)
Counter.value()
# => 16

# 4. Decrement
Counter.decrement(3)
Counter.value()
# => 13

# 5. Get the old value and update in one atomic step
old = Counter.get_and_increment(2)
# => 13          (old value)
Counter.value()
# => 15          (new value)

# 6. Reset
Counter.reset()
Counter.value()
# => 0

What’s happening under the hood

Function,What it does,Agent API used
start_link,Creates a process that holds the state,Agent.start_link/2
value,Reads the current state (does not change it),Agent.get/2
increment / decrement / reset,Changes the state,Agent.update/2
get_and_increment,Reads and updates atomically,Agent.get_and_update/2

Key points about Agent

An Agent is just a process that holds state.
State is completely private to that process (no shared memory).
All communication happens by sending messages (get, update, get_and_update).
Because it’s a process, it is isolated — a crash in the Agent doesn’t crash the caller (unless you link them).
Agents are perfect for simple state. For more complex behaviour (callbacks, handle_cast, handle_call, etc.) you would use a GenServer instead.

6. GenServer
The workhorse of OTP. Handles state, synchronous/asynchronous calls, and lifecycle.

Code:
defmodule CounterServer do
  use GenServer

  # =================================================
  # Client API (what the outside world calls)
  # =================================================

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

  def handle_call({:get_and_increment, by}, _from, state) do
    new_state = state + by
    {:reply, state, new_state}   # reply with old value, keep new state
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

  # Optional: clean-up when the process terminates
  @impl true
  def terminate(reason, state) do
    IO.puts("CounterServer terminating. Reason: #{inspect(reason)}, last state: #{state}")
    :ok
  end
end




How to use/run?
# Start the GenServer
{:ok, pid} = CounterServer.start_link(10)
# => {:ok, #PID<0.xxx.0>}

# Read the current value (synchronous)
CounterServer.value()
# => 10

# Increment / Decrement (asynchronous)
CounterServer.increment()
CounterServer.value()
# => 11

CounterServer.increment(5)
CounterServer.value()
# => 16

CounterServer.decrement(3)
CounterServer.value()
# => 13

# Get old value and update in one step
old = CounterServer.get_and_increment(2)
# => 13
CounterServer.value()
# => 15

# Reset
CounterServer.reset(0)
CounterServer.value()
# => 0

# Stop the server
CounterServer.stop()


Concept,How it appears in the code,Purpose

use GenServer,Top of the module,Brings in the behaviour
Client API,"start_link, value, increment…",Nice public interface
init/1,Sets the initial state,Runs once when the process starts
handle_call/3,Synchronous requests (caller waits),Used for value and get_and_increment
handle_cast/2,Asynchronous requests (fire-and-forget),"Used for increment, decrement, reset"
handle_info/2,Catches unexpected messages,Good practice
terminate/2,Clean-up callback,Called when the process dies


6. Supervisors
Supervisors monitor children and restart them according to a strategy.

Elixirchildren = [
  {Counter, 0},
  {Task.Supervisor, name: MyApp.TaskSupervisor}
]

opts = [strategy: :one_for_one, name: MyApp.Supervisor]
Supervisor.start_link(children, opts)
Common strategies:

:one_for_one – restart only the crashed child
:one_for_all – restart all children
:rest_for_one – restart the crashed one and those started after it

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

How to run it in iex
# Start the whole supervision tree
{:ok, _} = MyApp.Supervisor.start_link()

# Now the children are running
Counter.value()
# => 0

Counter.increment(5)
Counter.value()
# => 5

Counter.decrement(2)
Counter.value()
# => 3

# Use the Task.Supervisor
task = Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
  :timer.sleep(500)
  42 * 2
end)

Task.await(task)
# => 84

# You can also fire-and-forget under the supervisor
Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
  IO.puts("Background work running under supervision")
end)

Quick test of restart behaviour

# Kill the Counter process
Process.whereis(Counter) |> Process.exit(:kill)

# Wait a tiny bit for the supervisor to restart it
:timer.sleep(50)

# It is alive again with the initial state
Counter.value()
# => 0


7. Applications
An Application is a reusable component with a supervision tree

# mix.exs
def application do
  [
    extra_applications: [:logger],
    mod: {MyApp.Application, []}
  ]
end
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      MyApp.Repo,
      {Phoenix.PubSub, name: MyApp.PubSub},
      MyAppWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end

Application.start/1 (or mix run) starts the whole tree.

my_app/
├── mix.exs
├── lib/
│   ├── my_app/
│   │   ├── application.ex
│   │   ├── supervisor.ex
│   │   └── counter.ex
│   └── my_app.ex

1. mix.exs
defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # This is the important part – tells OTP which module is the Application
  def application do
    [
      extra_applications: [:logger],
      mod: {MyApp.Application, []}
    ]
  end

  defp deps do
    []
  end
end
2. lib/my_app/application.ex

defmodule MyApp.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Counter GenServer with initial value 0
      {Counter, 0},

      # Start a Task.Supervisor
      {Task.Supervisor, name: MyApp.TaskSupervisor}
    ]

    # :one_for_one → if one child dies, only that one is restarted
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

3. lib/my_app/counter.ex

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

4. lib/my_app.ex (optional helper)

defmodule MyApp do
  @moduledoc """
  Public API for the application.
  """

  def value, do: Counter.value()
  def increment(by \\ 1), do: Counter.increment(by)
  def decrement(by \\ 1), do: Counter.decrement(by)
  def reset(to \\ 0), do: Counter.reset(to)

  def run_background_job(fun) when is_function(fun, 0) do
    Task.Supervisor.start_child(MyApp.TaskSupervisor, fun)
  end
end

How to use it

# Create the project (if you haven't already)
mix new my_app --sup
# Then replace the generated files with the ones above

# Start the application
iex -S mix

Inside iex:
# The application is already started by OTP
Counter.value()
# => 0

Counter.increment(10)
Counter.value()
# => 10

# Use the Task.Supervisor
task = Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
  :timer.sleep(500)
  :done
end)

Task.await(task)
# => :done

# Or via the helper
MyApp.run_background_job(fn -> IO.puts("Hello from supervised task") end)

What an Application does
Component      Responsibility
mix.exs → application/0Declares the entry module (MyApp.Application)MyApp.ApplicationStarts the top-level Supervisor when the app bootsSupervisorStarts & monitors all children (Counter, Task.Supervisor, …)ChildrenYour GenServers, Agents, Task.Supervisors, etc.
When you run iex -S mix or start the release, OTP automatically calls MyApp.Application.start/2, which starts the whole supervision tree

Modern Replacement: DynamicSupervisor

# ============================================================
# 1. Counter GenServer (same as before)
# ============================================================
defmodule Counter do
  use GenServer

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value)
  end

  def value(pid), do: GenServer.call(pid, :value)
  def increment(pid, by \\ 1), do: GenServer.cast(pid, {:increment, by})
  def decrement(pid, by \\ 1), do: GenServer.cast(pid, {:decrement, by})

  @impl true
  def init(initial_value), do: {:ok, initial_value}

  @impl true
  def handle_call(:value, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast({:increment, by}, state), do: {:noreply, state + by}
  def handle_cast({:decrement, by}, state), do: {:noreply, state - by}
end

# ============================================================
# 2. DynamicSupervisor
# ============================================================
defmodule MyApp.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # :one_for_one is the only strategy DynamicSupervisor supports
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # ---------- Helper to start a Counter under the DynamicSupervisor ----------
  def start_counter(initial_value \\ 0) do
    child_spec = %{
      id: Counter,
      start: {Counter, :start_link, [initial_value]},
      restart: :temporary   # or :permanent / :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  # Convenience: start many counters
  def start_many(count, initial_value \\ 0) do
    Enum.map(1..count, fn _ -> start_counter(initial_value) end)
  end
end

# ============================================================
# 3. Application that starts the DynamicSupervisor
# ============================================================
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the DynamicSupervisor (it starts with ZERO children)
      {MyApp.DynamicSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

How to use it

# In iex -S mix  (or after starting the Application)

# Start individual counters dynamically
{:ok, pid1} = MyApp.DynamicSupervisor.start_counter(10)
{:ok, pid2} = MyApp.DynamicSupervisor.start_counter(100)

Counter.value(pid1)   # => 10
Counter.increment(pid1, 5)
Counter.value(pid1)   # => 15

Counter.value(pid2)   # => 100

# Start many at once
results = MyApp.DynamicSupervisor.start_many(3, 0)
# => [{:ok, #PID<...>}, {:ok, #PID<...>}, {:ok, #PID<...>}]

# See all running children
DynamicSupervisor.which_children(MyApp.DynamicSupervisor)

# Count how many children are alive
DynamicSupervisor.count_children(MyApp.DynamicSupervisor)
# => %{active: 5, specs: 5, supervisors: 0, workers: 5}

# Stop a specific child
DynamicSupervisor.terminate_child(MyApp.DynamicSupervisor, pid1)


Static Supervisor vs DynamicSupervisor
FeatureSupervisor (static)DynamicSupervisorChildren defined atCompile / start timeRuntimeStarting new childrenNot possible after startstart_child/2 anytimeStrategy:one_for_one, :one_for_all, :rest_for_oneOnly :one_for_oneTypical useFixed set of processes (Counter, Registry, etc.)Workers that come and go (connections, jobs, sessions…)Child restartConfigurable per childConfigurable per child