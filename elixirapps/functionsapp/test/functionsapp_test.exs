defmodule FunctionsappTest do
  use ExUnit.Case
  doctest Functionsapp

  test "greets the world" do
    assert Functionsapp.hello() == :world
  end
end
