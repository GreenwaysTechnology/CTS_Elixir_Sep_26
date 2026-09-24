# defmodule MyApp do
#   # Module code will go
#   IO.puts("Compiling....")
# end
# defmodule MyApp do
#   #  simple function
#   IO.puts("Module code compiling")
#   def hello do
#     # code
#     IO.puts("Function code....executing")
#   end
# end

defmodule MyApp do
  def init do
     Greeter.hello()
  end
end
