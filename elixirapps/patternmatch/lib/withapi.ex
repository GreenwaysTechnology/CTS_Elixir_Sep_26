defmodule Withapi do
  def get_user_email(user_id) do
    # when i call find_user , it returns the :ok with map  the output of finduser
    # will be input to the get_email, get_email returns final response
    with {:ok, user} <- find_user(user_id),
         {:ok, email} <- get_email(user) do
          # Final response
      {:ok, email}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def find_user(1) do
    {:ok, %{id: 1, email: "alice@example.com"}}
  end

  def find_user(_id) do
    {:error, :user_not_found}
  end

  def get_email(%{email: email}) do
    {:ok, email}
  end
end
