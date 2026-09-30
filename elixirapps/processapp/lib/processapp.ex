defmodule App.Process do
  def start_process do
    pid =
      spawn(fn ->
        IO.puts("Hello from process #{inspect(self())}")
      end)

    IO.inspect(pid)
  end
end

defmodule LinkDemo do
  def spawn_link_example do
    IO.puts("=== spawn_link example ===")

    Process.flag(:trap_exit, true)

    pid =
      spawn_link(fn ->
        IO.puts("Linked process started (pid: #{inspect(self())})")
        raise "boom from linked process"
      end)

    IO.puts("Spawned linked process: #{inspect(pid)}")

    receive do
      {:EXIT, ^pid, reason} ->
        IO.puts("Received EXIT from #{inspect(pid)}")
        IO.puts("Reason: #{inspect(reason)}")
    end

    IO.puts("Current process still alive")
  end

  def spawn_monitor_example do
    IO.puts("\n=== spawn_monitor example ===")

    {pid, ref} =
      spawn_monitor(fn ->
        IO.puts("Monitored process started (pid: #{inspect(self())})")
        raise "boom from monitored process"
      end)

    IO.puts("Spawned monitored process: #{inspect(pid)}")
    IO.puts("Monitor reference: #{inspect(ref)}")

    receive do
      {:DOWN, ^ref, :process, ^pid, reason} ->
        IO.puts("Received DOWN from #{inspect(pid)}")
        IO.puts("Reason: #{inspect(reason)}")
    end

    IO.puts("Current process still alive")
  end
end
