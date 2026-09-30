defmodule User do
  defstruct [:name, :age]
end

defmodule MyApp.Protocals do
  import User
  # define protocal : kind of interface in other languages(java..)
  defprotocol Size do
    # function
    @fallback_to_any true
    def size(data)
  end

  # implementation
  defimpl Size, for: Any do
    def size(_), do: 0
  end

  defimpl Size, for: BitString do
    def size(string) do
      byte_size(string)
    end
  end

  defimpl Size, for: Map do
    @spec size(map()) :: non_neg_integer()
    def size(map), do: map_size(map)
  end

  defimpl Size, for: List do
    def size(list), do: length(list)
  end

  defimpl Size, for: Tuple do
    def size(tuple), do: tuple_size(tuple)
  end

  defimpl Size, for: User do
    # two fields
    def size(%User{}), do: 2
  end
end
