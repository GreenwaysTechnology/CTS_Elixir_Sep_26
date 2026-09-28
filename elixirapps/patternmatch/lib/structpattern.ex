defmodule User do
  #keys cant be added to struct dynamically where as in map we can
  #in map there is default values , where structs can have default values
  # there compile time check, structs compile time checks
  
  defstruct id: 0, name: "", age: 18
end
