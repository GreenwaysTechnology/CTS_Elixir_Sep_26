defmodule MyApp.Anonymousfunction do
  def say_hello() do
    "Hello"
  end

  def start() do
    # delcare anonymous function
    add = fn a, b -> a + b end
    # ModuleName.function() = Named function
    # say_hello()
    # calling anonymous function
    IO.puts(add.(10, 10))
  end

  def info() do
    check_even = fn
      x when rem(x, 2) === 0 -> :ok
      _ -> :failed
    end

    IO.puts(check_even.(3))

    parse_response = fn
      {:ok, body} -> "Success! Received: #{body}"
      {:error, 404} -> "Not Found Error"
      {:error, :status} -> "Failed with status code: #{:status}"
    end

    # "Success! Received: Dashboard Data"
    # Pass tuple as parameter , function checkes tuple comparsion
    IO.puts(parse_response.({:ok, "Dashboard Data"}))
    IO.puts(parse_response.({:error, 404}))
    IO.puts(parse_response.({:error, :status}))

    who_is = fn
      "admin" -> "Welcome admin!"
      "guest" -> "Welcome Guest"
      _ -> "Dont Panic , Hacker is Here"
    end

    IO.puts(who_is.("admin"))
    IO.puts(who_is.("guest"))
    IO.puts(who_is.("Subramanian"))
  end

  def process_collection() do
    # passing function as parameter - anonymous functions
    is_even = fn x -> rem(x, 2) == 0 end
    data = Enum.filter([1, 2, 3, 4], is_even)
    IO.inspect(data)
    Enum.map([1, 2, 3], fn x -> x * 10 end)
  end

  # passing function as parameter to another function : higher order function
  # you can named function and also anonymous function -
end

defmodule MyApp.Callback do
  #
  def execute_greet(input \\ "Hey", callback) do
    # we are are going to call function
    # IO.inspect(callback)
    # invoke that function
    callback.(input)
  end

  # passing function
  def start_cb() do
    # call execute_greet
    my_hello = fn msg -> msg end
    execute_greet("How are you?", my_hello)
    execute_greet("How are you?", fn msg -> msg end)
  end
end
