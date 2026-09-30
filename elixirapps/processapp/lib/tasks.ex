defmodule TaskExamples do
  def fire_and_forget do
    IO.puts("\n=== 1. Fire and forget (Task.start) ===")

    {:ok, pid} =
      Task.start(fn ->
        IO.puts(" [background] Starting work in #{inspect(self())}")
        :timer.sleep(800)
        IO.puts(" [background] Work finished!")
      end)

    IO.puts("Spawned fire-and-forget task: #{inspect(pid)}")
    IO.puts("Main process continues immediately...")
    # just so we can see the background message
    :timer.sleep(1200)
    IO.puts("Main process finished.\n")
  end
end
