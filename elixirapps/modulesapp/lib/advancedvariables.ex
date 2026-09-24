defmodule Advancedvariables do
  @counter 10
  @counter 30

  # compiling 1 file (.ex)
  #   warning: module attribute @something was set but never used
  #   │
  # 5 │   @something "something"
  #   │   ~~~~~~~~~~~~~~~~~~~~~~
  #   │
  #   └─ lib/advancedvariables.ex:5: Advancedvariables (module)

  #Old elixir versions allow unused module attributes but recent version they deprecated
  # @unused_x 10

  def first_value do
    _something = "something "
    IO.puts(@counter)
  end

  @counter 20

  def second_value do
    IO.puts(@counter)
  end
end
