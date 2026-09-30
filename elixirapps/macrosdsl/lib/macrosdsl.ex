# Macro : logger
defmodule LoggerMacro do
  defmacro log(msg) do
    # macro code to be injected into the callers code during compile time
    quote do
      # this code will be injected into callers code during compile time
      IO.puts("[#{__ENV__.file}:#{__ENV__.line}] #{unquote(msg)}")
    end
  end
end

defmodule Getter do
  defmacro defgetter(name) do
    quote do
      def unquote(name)(map) do
        Map.get(map, unquote(name))
      end
    end
  end
end

defmodule Person do
  require Getter
  import Getter
  defgetter(:name)
  defgetter(:age)
end

defmodule App.LoggerModule do
  # inject Macro module
  require LoggerMacro
  import LoggerMacro

  def run do
    # inject macro
    log("Start")
    IO.puts("Your code")
    log("End")
  end
end

defmodule HTML do
  defmacro tag(name, do: block) do
    quote do
      "<#{unquote(name)}>" <> unquote(block) <> "</#{unquote(name)}>"
    end
  end

  defmacro tag(name, attrs, do: block) when is_list(attrs) do
    attr_string =
      attrs
      |> Enum.map(fn {k, v} -> " #{k}=\"#{v}\"" end)
      |> Enum.join()

    quote do
      "<#{unquote(name)}#{unquote(attr_string)}>" <>
        unquote(block) <>
        "</#{unquote(name)}>"
    end
  end
end

defmodule Page do
  require HTML
  import HTML

  def render do
    tag :div, class: "container" do
      tag :h1 do
        "Hello from a macro DSL"
      end <>
        tag :p do
          "This HTML was generated at compile time."
        end
    end
  end
end
