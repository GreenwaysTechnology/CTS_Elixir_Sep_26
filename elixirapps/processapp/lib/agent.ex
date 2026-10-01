defmodule Counter do
  @moduledoc """
  A simple stateful counter implemented with Agent.
  """
  # Start the Agent (holds the state)
  def start_link(initial_value \\ 0) do
    # spwan_link,Task.start
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  # Read the current state
  def value do
    Agent.get(__MODULE__, fn state -> state end)
  end

  # Update the state (increment)
  def increment(by \\ 1) do
    Agent.update(__MODULE__, fn state -> state + by end)
  end

  # Update the state (decrement)
  def decrement(by \\ 1) do
    Agent.update(__MODULE__, fn state -> state - by end)
  end

  # Reset the state
  def reset(to \\ 0) do
    Agent.update(__MODULE__, fn _state -> to end)
  end

  def get_and_increment(by \\ 1) do
    Agent.get_and_update(__MODULE__, fn state ->
      # {return_value, new_state}
      {state, state + by}
    end)
  end
end
