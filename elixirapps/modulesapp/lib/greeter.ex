defmodule Greeter do
  IO.puts("start...")
  @spec hello() :: :ok
  def hello do
     IO.puts("Greeter Module " <> " Hello")
  end
  IO.puts("end....")
end
