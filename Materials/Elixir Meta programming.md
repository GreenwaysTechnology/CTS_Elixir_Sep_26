**Elixir Metaprogramming, Macros & DSLs**

### Core Concepts

**Metaprogramming** means writing code that writes (or transforms) other code. In Elixir this happens almost exclusively at **compile time** via the Abstract Syntax Tree (AST).

Everything you write in Elixir is first turned into an AST (a nested tuple structure). Macros receive this AST, can inspect/transform it, and return a new AST that is then compiled.

**Macros** are the main tool.  
- Defined with `defmacro`  
- Receive the AST of their arguments (not the evaluated values)  
- Must return valid Elixir AST  
- Are expanded at compile time → zero runtime cost for the macro itself  

**Quote / Unquote**  
- `quote` creates an AST from Elixir code  
- `unquote` injects a value into that AST  
- This is the classic “code as data” pattern

**DSLs (Domain-Specific Languages)**  
Elixir’s syntax is deliberately flexible. By combining macros + the pipe operator + special forms you can create highly readable mini-languages for a particular problem domain (Phoenix routers, Ecto queries, ExUnit tests, Absinthe GraphQL schemas, etc.).

---

### 1. Simple Macro – Logging with location

```elixir
defmodule LoggerMacro do
  defmacro log(msg) do
    quote do
      IO.puts("[#{__ENV__.file}:#{__ENV__.line}] #{unquote(msg)}")
    end
  end
end

defmodule Demo do
  require LoggerMacro
  import LoggerMacro

  def run do
    log("Hello from a macro!")
    log("Another message")
  end
end

Demo.run()
```

**Output (compile-time location is baked in):**
```
[.../your_file.ex:12] Hello from a macro!
[.../your_file.ex:13] Another message
```

---

### 2. Macro that generates functions (classic metaprogramming)

```elixir
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

  defgetter :name
  defgetter :age
end

person = %{name: "Alice", age: 30}
IO.inspect(Person.name(person))  # => "Alice"
IO.inspect(Person.age(person))   # => 30
```

---

### 3. Tiny DSL – a simple “unless” (control-flow DSL)

Elixir already has `unless`, but here is how you would implement it yourself:

```elixir
defmodule Control do
  defmacro my_unless(condition, do: block) do
    quote do
      if !unquote(condition) do
        unquote(block)
      end
    end
  end
end

defmodule DSLDemo do
  require Control
  import Control

  def run do
    my_unless 1 + 1 == 3 do
      IO.puts("Math still works!")
    end

    my_unless true do
      IO.puts("This will never print")
    end
  end
end

DSLDemo.run()
```

---

### 4. Slightly richer DSL – a mini HTML builder

```elixir
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

IO.puts(Page.render())
```

**Output:**
```html
<div class="container"><h1>Hello from a macro DSL</h1><p>This HTML was generated at compile time.</p></div>
```

---

### Key Takeaways

| Concept            | What it does                                      | When it runs     |
|--------------------|---------------------------------------------------|------------------|
| `quote`            | Turns code → AST                                  | Compile time     |
| `unquote`          | Injects a value into an AST                       | Compile time     |
| `defmacro`         | Defines a macro                                   | Compile time     |
| Macro expansion    | Replaces the macro call with the returned AST     | Compile time     |
| DSL                | Combination of macros + Elixir syntax sugar       | Compile time     |

Macros are extremely powerful but should be used sparingly. Prefer functions when possible; reach for macros only when you need to change the language itself (new syntax, compile-time code generation, domain-specific readability).

You can paste any of the examples above into an `iex` session or a `.exs` file and run them directly.