defmodule StatefulProperty.StatefulProper do
  use ExUnit.Case
  use PropCheck
  use PropCheck.StateM # <-- use this is one for stateful properties
#  use PropCheck.FSM  # <-- use this one for FSM properties
#  doctest StatefulProperty.FsmExampleProper


  ## Stateful property example

  property "stateful property" do
    forall cmds <- commands(__MODULE__) do
      #ActualSystem.start_link()
      #IO.inspect cmds, label: "commands"
      {history, state, result} = run_commands(__MODULE__, cmds)
      #ActualSystem.stop()

      IO.inspect result, label: "                    run_cmds res"
      (result == :ok)
      |> aggregate(command_names(cmds))
      |> when_fail(
           IO.puts("""
           History: #{inspect(history)}
           State: #{inspect(state)}
           Result: #{inspect(result)}
           """)
         )
    end
  end

  # Initial model value at system start. Should be deterministic.
  def initial_state() do
    #IO.puts "*initial_state"
    %{
      current: :first,
      first: :second,
      second: :third,
      third: :fourth,
      fourth: :fivth,
      fivth: :first
    }
  end

  # List of possible commands to run against the system
  def command(%{current: :first} = state) do
    IO.puts "*first#"
    {:call, StatefulProperty.Cache, :some_call, [term(), term()]}
  end

  def command(%{current: :third} = state) do
    IO.puts "*thirt#"
    {:call, StatefulProperty.Cache, :some_another_call, [term(), term()]}
  end

  def command(%{current: :fivth} = state) do
    IO.puts "*fivth#"
    {:call, StatefulProperty.Cache, :yet_another_call, [term(), term()]}
  end

  # select randomly
  def command(_state) do
    #IO.puts "*command"
    oneof([
      {:call, StatefulProperty.Cache, :some_call, [term(), term()]},
      {:call, StatefulProperty.Cache, :some_another_call, [term(), term()]},
      {:call, StatefulProperty.Cache, :yet_another_call, [term(), term()]}
    ])
  end


  # Determines whether a command should be valid under the current state
  def precondition(_state, {:call, _mod, _fun, _args}) do
    #IO.puts "*precondition"
    true
  end

  # Given that state prior to the call `{:call, mod, fun, args}`,
  # determine whether the result (res) coming from the actual system
  # makes sense according to the model
  def postcondition(_state, {:call, _mod, _fun, _args}, res) do
    #IO.puts """
    #  *postcondition"
    #  res: #{ res }
    #  """
    true
  end

  # Assuming the postcondition for a call was true, update the model
  # accordingly for the test to proceed
  def next_state(state, res, {:call, _mod, _fun, _args}) do
    #IO.puts "*next_state"
    #IO.inspect state, label: "state"
    #IO.inspect state[:current], label: "current"
    #IO.inspect res, label: "::next state res"
    next = state[:current]
    newstate = %{state | current: state[next]}
    newstate
  end

end