defmodule Greeter do
  # basic function declaration
  def hello() do
    # function body
    IO.puts("Hello function")
  end

  def more_hello do
    IO.puts("Hello function")
    IO.puts("Hello function")
    IO.puts("Hello function")
    IO.puts("Hello function")
    IO.puts("Hello function")
    IO.puts("Hello function")
    IO.puts("Hello function")
  end

  # function with parameters
  def sayHello(name \\ "Elixir") do
    IO.puts("Hello #{name}")
  end
end

defmodule Calc do
  def add(a \\ 0, b \\ 0) do
    c = a + b
    IO.puts(c)
  end
end

# Function returns: In Elixir there is no function return statement , last line of the function
# is returned

defmodule Receipt do
  def format_price(amount \\ 1.0, currency \\ "$") do
    # Return value
    "#{currency}#{amount}"
  end
end

defmodule MyApp.Login do
  defp auth(_username \\ "", _password \\ "") do
    "Login Success"
  end

  @spec login() :: <<_::104>>
  def login(_name \\ "", _password \\ "") do
    auth()
  end
end

defmodule Main do
  # import Greeter
  # import Calc
  # import Receipt
  import MyApp.Login

  # def init() do
  #   # Invoke function
  #   hello()
  #   more_hello()
  # end
  # def init() do
  #   sayHello("Subramanian Murugan")
  #   sayHello()
  #   add(10, 10)
  #   add()

  # end
  # def init() do
  #   result = format_price(100.89)
  #   IO.puts(result)
  # end
  def init do
    login()
  end
end
