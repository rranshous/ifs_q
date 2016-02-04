# This is the dispatcher
# The dispatcher takes messages from the outside world and sends them to workers and archivers

defmodule IfsQ.Dispatcher do
  require IEx
  use GenServer

  def start(name) do
    GenServer.start(IfsQ.Dispatcher, nil, name: name)
  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def handle_call({:dispatch, message, unit_id}, _, state) do
    {:ok, pid, state} = pid_for(state, unit_id)
    dispatch(pid, message, unit_id)
    { :reply, { :ok }, state }
  end

  def handle_call({:kill_pids}, _, state) do
    HashDict.values(state)
    |> Enum.each(fn(pid) -> Process.exit(pid, :kill) end)
    { :reply, :ok , HashDict.new }
  end

  def handle_call({:state}, _, state) do
    {:reply, {:ok, state}, state}
  end

  defp pid_for(state, unit_id) do
    HashDict.fetch(state, unit_id)
    |> return_living_pid(state, unit_id) 
  end

  defp return_living_pid(:error, state, unit_id), do: make_a_new_pusher(state, unit_id)
  defp return_living_pid({:ok, pid}, state, unit_id) do
    case Process.alive? pid do
      true -> {:ok, pid, state}
      false -> make_a_new_pusher(state, unit_id)
    end
  end
    
  defp make_a_new_pusher(state, unit_id) do
    {:ok, pid} = IfsQ.Pusher.start(process_identifier(unit_id))
    pid_for(HashDict.put(state, unit_id, pid), unit_id)
  end

  defp dispatch(pid, message, unit_id) do
    GenServer.cast(pid, {:dispatch, message, unit_id})
  end
  defp process_identifier(unit_id), do: unit_id |> (&("ifs_pusher_" <> &1)).() |> String.to_atom
end
