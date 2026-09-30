defmodule Pipelines do
  def process_enum() do
    1..10
    |> Enum.map(&(&1 * 2))
    |> Enum.filter(&(&1 > 3))
    |> Enum.sum()
  end

  def process_stream do
    stream =
      1..10
      |> Stream.map(&(&1 * 2))
      |> Enum.filter(&(&1 > 3))
    #Execution triggers only when Enum.sum consumes the stream
    Enum.sum(stream)
  end
end
