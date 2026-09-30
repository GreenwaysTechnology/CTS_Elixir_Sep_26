defmodule ProcessappTest do
  use ExUnit.Case
  doctest Processapp

  test "greets the world" do
    assert Processapp.hello() == :world
  end
end
