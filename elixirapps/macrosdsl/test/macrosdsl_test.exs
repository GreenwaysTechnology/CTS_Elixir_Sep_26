defmodule MacrosdslTest do
  use ExUnit.Case
  doctest Macrosdsl

  test "greets the world" do
    assert Macrosdsl.hello() == :world
  end
end
