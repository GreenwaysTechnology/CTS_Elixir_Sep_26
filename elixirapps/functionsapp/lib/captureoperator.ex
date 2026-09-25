defmodule MyApp.Calc do
  def add(a, b) do
    a + b
  end
end

defmodule MyApp.Capture.Greeter do
  def greeter(msg) do
    msg
  end

  def execute_greet(input \\ "Hey", callback) do
    callback.(input)
  end
end

defmodule MyApp.MathTools do
  def triple(number) do
    number * 3
  end

  def process_list(list) do
    # triple is passed as parameter to map function
    Enum.map(list, &triple/1)
  end
end

defmodule MyApp.Captureoperator do
  import MyApp.Calc
  import MyApp.MathTools
  import MyApp.Capture.Greeter

  def do_stuff() do
    name = "subramanian murugan"
    uppername = String.upcase(name)
    IO.puts("#{name} #{uppername}")
    # simplify using Capture operator /1 means arity - no of args
    uppercase = &String.upcase/1
    # call function
    IO.puts("#{uppercase.(name)}")
    # without capture operator
    IO.puts(add(19, 10))
    # Assign Named function to a variable using caputre operator
    sum = &MyApp.Calc.add/2
    IO.puts(sum.(90, 10))
    process_list([1, 3, 4])

    # Assign greeter function into a variable
    cbgreet = &MyApp.Capture.Greeter.greeter/1
    execute_greet("Greet with Capture Operator", cbgreet)
    execute_greet("Greet with Capture Operator inline", &MyApp.Capture.Greeter.greeter/1)
  end
end

defmodule MyApp.MathEngine do
  def run_pipeline() do
    add_numbers = fn a, b -> a + b end
    # Returns 15
    IO.puts("Add : #{add_numbers.(5, 10)}")
    # pass anonymous function with help of Capture operator
    substract_numbers = &(&1 - &2)
    IO.puts("Substract #{substract_numbers.(10, 4)}")
  end
end
