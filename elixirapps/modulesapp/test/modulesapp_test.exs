defmodule ModulesappTest do
  use ExUnit.Case
  doctest Modulesapp

  test "greets the world" do
    assert Modulesapp.hello() == :world
  end
end
