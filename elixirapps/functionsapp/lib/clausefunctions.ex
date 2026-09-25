defmodule MyApp.Clause do
  # Without guard :Clause
  def login("admin") do
    "Welcome to the Master Control Panel"
  end

  def login("guest") do
    "Welcome! You have limited access"
  end

  def login(user) do
    "Welcome! #{user}"
  end
end

defmodule MyApp.PaymentProcessor do
  def process_payment(amount, "stripe") when amount > 0 do
    {:ok, "Payment Processed via Stripe"}
  end

  def process_payment(amount, "paypal") when amount > 0 do
    {:ok, "Payment Processed via Paypal"}
  end

  def process_payment(amount, "upi") when amount > 0 do
    {:ok, "Payment Processed via UPI"}
  end

  def process_payment(_amount, _unknownprovider) do
    #  IO.puts(amount)
    #  IO.puts(unknownprovider)
    {:invalid_amt, :invalid_provider}
  end
end
