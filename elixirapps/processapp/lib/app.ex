defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start Counter with initial value 0
      {CounterServer, 0},
      # Start a Task.Supervisor
      {Task.Supervisor, name: MyApp.TaskSupervisor}
    ]

    # :one_for_one → if one child dies, only that one is restarted
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
