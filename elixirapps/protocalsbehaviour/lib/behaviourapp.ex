defmodule MyApp.Parser do
  @moduledoc "A behaviour for parsing data into a known format"
  @doc "Parses the given input and returns {:ok, result} or {:error, reason}"
  @callback parse(input :: term()) :: {:ok, term()} | {:error, term()}

  @doc "Returns a human-readable name for this parser"
  @callback name() :: String.t()

  @callback validate(input :: term()) :: boolean()

  @optional_callbacks validate: 1
end

defmodule MyApp.JSONParser do
  @behaviour MyApp.Parser

  @impl true
  def parse(input) when is_binary(input) do
    case Jason.decode(input) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse(_), do: {:error, :invalid_input}

  @impl true
  def name, do: "JSON Parser"

  @impl true
  def validate(input) when is_binary(input), do: String.trim(input) != ""
  @impl true
  def validate(_), do: false
end

defmodule MyApp.CSVParser do
  @behaviour MyApp.Parser
  @impl true
  def parse(input) when is_binary(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))

    {:ok, rows}
  end

  def parse(_), do: {:error, :invalid_input}
  @impl true
  def name, do: "CSV Parser"
end

defmodule MyApp.ParserRunner do
  def run(parser_module, input) do
    # We can rely on the contract
    IO.puts("Using: #{parser_module.name()}")

    case parser_module.parse(input) do
      {:ok, result} ->
        IO.inspect(result, label: "Parsed")
        :ok

      {:error, reason} ->
        IO.puts("Failed: #{inspect(reason)}")
        :error
    end
  end
end
