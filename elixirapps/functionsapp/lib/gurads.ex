defmodule MyApp.Guards do
  # keep the different drive function version
  def drive(age) when age >= 18, do: :allowed
  def drive(_), do: :denied

  # Custom Guards: we can define our own rules for Guards
  defguard is_adult(age) when is_integer(age) and age >= 18

  def can_vote(age) when is_adult(age), do: "You can vote"
  def can_vote(_), do: "You cant vote"
end
