defmodule ConfigReader do
  def read_config do
    case File.read("config.json") do
      {:ok, content} ->
        Jason.decode!(content)

      {:error, :enoent} ->
        %{"defaults" => true}

      {:error, reason} ->
        raise "Failed to read config: #{reason}"
    end
  end
end

defmodule FunctionHeads do
  # With Case
  # def handle(result) do
  #   case result do
  #     {:ok, body} ->
  #       {:ok, body}
  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end
  # With Function Heads
  def handle({:ok, body}), do: {:ok, body}
  def handle({:error, reason}), do: {:error, reason}
end
