defmodule Variables do
  # variables you declare has to be used
  # You cant declare Traditional variables inside module
  # Here no = operator
  # @firstname = "Subramanian"
  # Module attributes
  @firstname "Subramanian"
  @lastname "Murugan"
  @counter 10
  @points 20.5
  @status :ok
  @error :error
  @skils ["java", "Mainframe", "Elixir", "OTP", "Erlang"]

  def print_info do
    # local variables
    message = "Hello"
    IO.puts(message <> @firstname <> @lastname)
    # Interpolation to print other than string variables
    IO.puts("The Counter is : #{@counter} ")
    IO.puts("The Points is : #{@points} ")
    IO.puts("The Status is : #{@status} ")
    IO.puts("The error is : #{@error} ")
    IO.inspect(@points)
    IO.inspect(@skils)
  end
end
