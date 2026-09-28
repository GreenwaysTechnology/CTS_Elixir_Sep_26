defmodule PatternmatchTest do
  use ExUnit.Case
  doctest Patternmatch

  test "greets the world" do
    assert Patternmatch.hello() == :world
  end
end
