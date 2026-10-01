defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Start Counter with initial value 0
      {CounterServer, 0},
      # Start a Task.Supervisor
      {Task.Supervisor, name: MyApp.TaskSupervisor}
    ]

    # one_for_one = if one child dies, only that child is restarted
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
