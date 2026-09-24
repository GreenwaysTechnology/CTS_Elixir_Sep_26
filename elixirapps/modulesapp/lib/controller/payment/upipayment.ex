defmodule MyApp.Controller.Payment.UpiPayment do
  # Will import all functions from the given module == import * from java.lang
  import MyAppRepo.Payment.Paymentrepo
  # what if i want only specific functions
  # only means only those functions available, [funName:numberofargs]
  import MyApp.MyMath.Math, only: [add: 0, substract: 0]
  @spec transfer() :: <<_::176>>
  def transfer() do
    # MyAppRepo.Payment.Paymentrepo.save()
    save()
  end

  def calc() do
    IO.puts("add #{add()}")
    IO.puts("substract #{substract()}")
    # IO.puts("multiply #{multiple()}")
  end
end
