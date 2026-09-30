defmodule ProtocalsbehaviourTest do
  use ExUnit.Case
  doctest Protocalsbehaviour

  test "greets the world" do
    assert Protocalsbehaviour.hello() == :world
  end
end
