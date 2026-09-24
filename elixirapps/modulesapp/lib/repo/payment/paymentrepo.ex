defmodule MyAppRepo.Payment.Paymentrepo do
  alias MyApp.Model.Payment.Paymentmodel

  def save() do
    # MyApp.Model.Payment.Paymentmodel.save()
    Paymentmodel.save()
  end
end
