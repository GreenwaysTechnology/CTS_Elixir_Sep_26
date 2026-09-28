defmodule TuplePattern do
  def divide(a, b) do
    if b == 0 do
      #   "B cant be zero"
      {:error, "Cant divide by Zero"}
    else
      {:ok, a / b}
    end
  end

  # def add({a, b}) do
  #   a + b
  # end
  #   def add({a, b}) do
  #     a + b
  #   end
  #   def add(points \\ {0, 0}) do
  #     {a, b} = points
  #     a + b
  #   end
  def add({a, b} \\ {0, 0}) do
    # {a, b} = points
    a + b
  end

  #   def add(tup) do
  #     {a, b} = tup
  #     a + b
  #   end

  #   Tuple , pattern matching with clauses
  def greet({:admin, name}), do: "Welcome to #{name}"
  def greet({:guest, name}), do: "Welcome #{name}"

  # Tuple , pattern matching, anonmous functions
  def myFun() do
    logger = fn
      {status, msg} -> {:info, "something #{status} #{msg}"}
    end

    # logger.()
    logger.({"xxx", "yyy"})
  end
end

defmodule ListPattern do
  #   def listFun(list) do
  #     IO.inspect(list)
  #   end
  def listFun([head | tail]) do
    IO.inspect(head)
    IO.inspect(tail)
  end
end
