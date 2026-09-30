**Elixir Protocols** provide a way to achieve polymorphism. They let you define a set of functions that different data types can implement, so the same function call works correctly for many types.

Think of them as interfaces (or type classes in Haskell / traits in Rust), but with Elixir’s dynamic nature and pattern-matching style.

### Core Concepts

1. **Protocol** – Declares *what* functions must be available.
2. **Implementation (`defimpl`)** – Provides the actual code for a concrete type.
3. **Dispatch** – At runtime Elixir looks at the data’s type and calls the matching implementation.
4. **Fallback / Any** – You can give a default implementation for types that don’t have a specific one.
5. **Built-in protocols** – `Enumerable`, `Collectable`, `Inspect`, `String.Chars`, `List.Chars`, `Access`, etc.

### 1. Defining a Protocol

```elixir
defprotocol Size do
  @doc "Calculates the size of a data structure"
  def size(data)
end
```

### 2. Implementing the Protocol

```elixir
defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: List do
  def size(list), do: length(list)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end
```

### 3. Using the Protocol

```elixir
Size.size("hello")          # => 5
Size.size(%{a: 1, b: 2})    # => 2
Size.size([1, 2, 3, 4])     # => 4
Size.size({1, 2, 3})        # => 3
```

### 4. Fallback Implementation (`Any`)

```elixir
defimpl Size, for: Any do
  def size(_), do: 0          # or raise, or whatever default you want
end
```

You can also mark the protocol itself with `@fallback_to_any true` so unimplemented types automatically use the `Any` implementation.

### 5. Protocol for Structs

```elixir
defmodule User do
  defstruct [:name, :age]
end

defimpl Size, for: User do
  def size(%User{}), do: 2    # two fields
end

Size.size(%User{name: "Alice", age: 30})  # => 2
```

### 6. Common Built-in Protocols – Quick Examples

**`Enumerable`** (used by `Enum` and `Stream`)

```elixir
Enum.map([1, 2, 3], &(&1 * 2))          # works because List implements Enumerable
Enum.map(%{a: 1, b: 2}, fn {k, v} -> {k, v * 2} end)
```

**`String.Chars`** (used by `to_string/1` and string interpolation)

```elixir
defimpl String.Chars, for: User do
  def to_string(%User{name: name, age: age}) do
    "#{name} (#{age})"
  end
end

"Hello #{%User{name: "Bob", age: 25}}"   # => "Hello Bob (25)"
```

**`Inspect`** (controls how data appears in the console / `inspect/1`)

```elixir
defimpl Inspect, for: User do
  def inspect(%User{name: name, age: age}, _opts) do
    "#User<#{name}, #{age}>"
  end
end
```

### 7. Deriving Protocols (convenient for structs)

```elixir
defmodule Point do
  @derive [Inspect, Size]   # if Size is already defined for maps/structs
  defstruct [:x, :y]
end
```

### 8. Checking Whether a Type Implements a Protocol

```elixir
Size.impl_for("hello")          # => Size.BitString
Size.impl_for(%{})              # => Size.Map
Size.impl_for(123)              # => nil  (or Size.Any if fallback is enabled)
```

### Practical Mini-Example: A `Blank` Protocol

```elixir
defprotocol Blank do
  @doc "Returns true if the data is considered blank"
  def blank?(data)
end

defimpl Blank, for: BitString do
  def blank?(""), do: true
  def blank?(_),  do: false
end

defimpl Blank, for: List do
  def blank?([]), do: true
  def blank?(_),  do: false
end

defimpl Blank, for: Map do
  def blank?(map), do: map_size(map) == 0
end

defimpl Blank, for: Atom do
  def blank?(nil),  do: true
  def blank?(false), do: true
  def blank?(_),    do: false
end

# Usage
Blank.blank?("")          # true
Blank.blank?("hi")        # false
Blank.blank?([])          # true
Blank.blank?(%{})         # true
Blank.blank?(nil)         # true
Blank.blank?(0)           # error (no implementation) unless you add Any
```

### Key Takeaways

- Protocols give you **open polymorphism** – you can add implementations for types you don’t own.
- Dispatch is based on the **concrete type** of the first argument.
- Prefer protocols when you need the same behaviour across many different data shapes.
- Prefer behaviours (`@behaviour`) when you want modules to implement a known set of callbacks (more OOP-style).


**Elixir Behaviours** define a contract that a module must fulfill. They specify a set of functions (callbacks) that any implementing module is expected to provide.

They are the primary way Elixir expresses “this module must implement these functions,” and they power almost all of OTP (GenServer, Supervisor, Application, Agent, Task, etc.).

### Core Concepts

| Concept              | Meaning |
|----------------------|--------|
| **Behaviour**        | A module that declares required (and optional) callbacks using `@callback` |
| **Callback**         | A function specification that implementing modules must (or may) define |
| **`@behaviour`**     | Attribute a module uses to declare that it implements a behaviour |
| **Compiler check**   | Elixir warns at compile time if required callbacks are missing |
| **Optional callbacks** | Declared with `@optional_callbacks` – implementing them is not mandatory |

**Behaviours vs Protocols**

- **Behaviour** → contract between **modules** (compile-time, static)
- **Protocol** → polymorphism over **data types** (runtime dispatch)

### 1. Defining a Behaviour

```elixir
defmodule Parser do
  @moduledoc "A behaviour for parsing data into a known format"

  @doc "Parses the given input and returns {:ok, result} or {:error, reason}"
  @callback parse(input :: term()) :: {:ok, term()} | {:error, term()}

  @doc "Returns a human-readable name for this parser"
  @callback name() :: String.t()

  # Optional callback
  @callback validate(input :: term()) :: boolean()
  @optional_callbacks validate: 1
end
```

**Explanation of that line**

```elixir
@callback perform(state :: term()) :: {:ok, new_state :: term()} | {:error, reason :: term()}
```

### 1. What is `::`?

`::` is the **typespec operator**.  
It means: “this thing has the following type”.

- On the **left** side of `::` → the name of the argument or the return value
- On the **right** side of `::` → the type

So:

| Part                        | Meaning                                      |
|----------------------------|----------------------------------------------|
| `state :: term()`          | The argument called `state` has type `term()` |
| `:: {:ok, ...} \| {:error, ...}` | The function **returns** one of those two tuples |

### 2. What is `term()`?

`term()` is the **most general type** in Elixir.  
It means **“any Elixir value”**.

Everything in Elixir is a `term`:

- integers, floats, atoms, strings, lists, maps, tuples, pids, functions, structs… everything.

So when you write:

```elixir
state :: term()
```

you are saying: “I accept **any** value as the `state` argument.”

### Breaking the whole line down

```elixir
@callback perform(state :: term()) :: {:ok, new_state :: term()} | {:error, reason :: term()}
```

| Piece                        | Meaning |
|-----------------------------|---------|
| `@callback`                 | This is a required function that modules implementing the behaviour must define |
| `perform(...)`              | The function name and its parameters |
| `state :: term()`           | First (and only) argument is named `state` and can be any value |
| `::` (after the parameters) | “This function returns…” |
| `{:ok, new_state :: term()}`| Success case: a tuple with `:ok` and a new state (any value) |
| `\|`                        | or |
| `{:error, reason :: term()}`| Error case: a tuple with `:error` and a reason (any value) |

### More precise types (better style)

You will often see people write more specific types instead of `term()`:

```elixir
@callback perform(state :: map()) :: 
  {:ok, new_state :: map()} | 
  {:error, reason :: atom() | String.t()}
```

Or using a custom type:

```elixir
@type state :: map()
@type reason :: atom() | String.t()

@callback perform(state) :: {:ok, state} | {:error, reason}
```

### Quick summary

| Symbol / Word | Meaning |
|---------------|--------|
| `::`          | “has the type” |
| `term()`      | any Elixir value |
| `@callback`   | declares a required function for the behaviour |


### 2. Implementing a Behaviour

```elixir
defmodule JSONParser do
  @behaviour Parser

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

  # Optional callback – we choose to implement it
  @impl true
  def validate(input) when is_binary(input), do: String.trim(input) != ""
  def validate(_), do: false
end
```

```elixir
defmodule CSVParser do
  @behaviour Parser

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

  # We skip the optional `validate/1` – no warning
end
```

### 3. Using the Behaviour

```elixir
defmodule ParserRunner do
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

# Usage
ParserRunner.run(JSONParser, ~s({"name": "Alice", "age": 30}))
ParserRunner.run(CSVParser, "name,age\nAlice,30\nBob,25")
```

### 4. The `@impl` Attribute (recommended)

```elixir
@impl true          # tells the compiler this function implements a callback
@impl Parser        # more explicit – implements a callback from Parser
@impl false         # explicitly marks a function as *not* a callback
```

Using `@impl true` gives better compiler warnings and makes the code self-documenting.

### 5. Real-World Example – A Simple Worker Behaviour

```elixir
defmodule Worker do
  @moduledoc "Behaviour for background workers"

  @callback init(args :: term()) :: {:ok, state :: term()} | {:error, reason :: term()}
  @callback perform(state :: term()) :: {:ok, new_state :: term()} | {:error, reason :: term()}
  @callback terminate(reason :: term(), state :: term()) :: :ok
end

defmodule EmailWorker do
  @behaviour Worker

  @impl true
  def init(opts) do
    {:ok, %{queue: opts[:queue] || "default", retries: 0}}
  end

  @impl true
  def perform(state) do
    # pretend to send an email
    IO.puts("Sending email from queue: #{state.queue}")
    {:ok, %{state | retries: 0}}
  end

  @impl true
  def terminate(_reason, _state), do: :ok
end
```

### 6. OTP Behaviours (the most common use)

Almost every OTP module is a behaviour:

```elixir
defmodule MyServer do
  use GenServer          # expands to @behaviour GenServer + default implementations

  # You only implement the callbacks you care about
  @impl true
  def init(initial_value) do
    {:ok, initial_value}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set, value}, _state) do
    {:noreply, value}
  end
end
```

Other important OTP behaviours:

- `Supervisor`
- `Application`
- `GenServer`
- `Agent`
- `Task`
- `Registry`
- `DynamicSupervisor`

### 7. Checking Implementations at Runtime

```elixir
# Returns true if the module implements the behaviour
function_exported?(JSONParser, :parse, 1)   # true

# Or more precisely:
Code.ensure_loaded?(JSONParser) &&
  function_exported?(JSONParser, :parse, 1)
```

### 8. Best Practices

- Always use `@impl true` (or `@impl BehaviourName`) on callback implementations.
- Prefer `@optional_callbacks` for functions that are nice-to-have.
- Document every `@callback` with `@doc`.
- Keep the behaviour focused – one clear responsibility.
- When you control both the behaviour and the implementations, consider whether a simple module + pattern matching would be clearer.

### Quick Comparison Recap

| Feature            | Behaviour                          | Protocol                          |
|--------------------|------------------------------------|-----------------------------------|
| Target             | Modules                            | Data types                        |
| Dispatch           | Compile-time / explicit module     | Runtime (based on data type)      |
| Common use         | OTP, plugins, strategies           | Enumerable, Inspect, String.Chars |
| Missing impl       | Compiler warning                   | Runtime error (or fallback)       |

