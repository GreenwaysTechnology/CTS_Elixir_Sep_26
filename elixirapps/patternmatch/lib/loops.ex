defmodule Loops do
  def forloop do
    # Comprehension
    # for n <- [1, 2, 3, 4], do: n * n
    # Enum.map
    Enum.map([1, 2, 3, 4], fn x -> x * x end)
  end
end

defmodule Recurssion do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end
