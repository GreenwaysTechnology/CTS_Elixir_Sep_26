defmodule MyApp.Paymentgateway do
  @moduledoc """
    Defines the contract for all payment processors
  """
  # define the required function signature(Blude print)
  # Function should take int as arg and must return tuple with status
  @callback charge(amount :: integer()) :: {:ok, binary()} | {:error, term()}
end

# Implementation (contract) - Worker Modules - It must implement the contract

defmodule MyApp.StripProcessor do
  # 1.Adpot the Behaviour contract
  @behaviour MyApp.Paymentgateway
  #implementation
  @impl MyApp.Paymentgateway
  def charge(amount) do
    {:ok, "Strip charges #{amount}"}
  end
end
