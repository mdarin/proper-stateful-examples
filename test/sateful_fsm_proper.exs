defmodule StatefulProperty.StatefulFSMProper do
  use ExUnit.Case
  use PropCheck
  #use PropCheck.StateM # <-- use this is one for stateful properties
    use PropCheck.FSM  # <-- use this one for FSM properties
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
      |> aggregate(
        #:proper_statem.zip(state_names(history), command_names(cmds)
        command_names(cmds)
      )
      |> when_fail(
           IO.puts("""
           History: #{inspect(history)}
           State: #{inspect(state)}
           Result: #{inspect(result)}
           """)
         )
    end
  end

  # Initial state for the state machine
  def initial_state(), do: :on

  # Initial model at the start. Should be deterministic
  def initial_state_data(), do: %{}

  # State command generation
  def on(_data) do
    IO.puts "**ON"
    [
      {:off, {:call, StatefulProperty.Cache, :some_call, [term(), term()]}}
    ]
  end
  def off(_data) do
    IO.puts "**OFF"
    [
      {:off, {:call, StatefulProperty.Cache, :some_another_call, [term(), term()]}},
#      {:history, {:call, StatefulProperty.Cache, :some_call, [term(), term()]}},
      # Following this, a transition can be made to a nested state, at ❸. A nested
      # state is built as a tuple of the form {ParentState, SubState, SubSubState} , and the
      # callback for it is shown at ❹: ParentState(SubState, SubSubState, Data) .
#      {{:service, :sub, :state}, {:call, StatefulProperty.Cache, :some_call, [term(), term()]}} # ❸
    ]
  end

  # ❹
  def service(_sub, _state, _data) do
    [
      {:on, {:call, StatefulProperty.Cache, :some_call, [term(), term()]}}
    ]
  end

  # Optional callback, weight modification of transitions
  def weight(_from_state, _to_state, _call), do: 1

  # Picks whether a command should be valid
  def precondition(_from, _to, _data, {:call, _mod, _fun, _args}) do
    true
  end

  # Given that state prior to the call `{:call, mod, fun, args}`,
  # determine whether the result (res) coming from the actual system
  # makes sense according to the model
  def postcondition(_from, _to, _data, {:call, _mod, _fun, _args}, _res) do
    true
  end

  # Assuming the postcondition for a call was true, update the model
  # accordingly for the test to proceed
  def next_state_data(_from, _to, data, _res, {:call, _m, _f, _args}) do
    new_data = data
    new_data
  end
end
