# This is the dispatcher
# The dispatcher takes messages from the outside world and sends them to workers and archivers

defmodule IfsQ.Dispatcher do
  require IEx
  use GenServer

  def start() do
    GenServer.start(IfsQ.Dispatcher, nil)
  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def handle_call({:dispatch, message, unit_id}, _, state) do
    {:ok, {:ok, pid}, state} = pid_for(state, unit_id)
    dispatch(pid, message, unit_id)
    { :reply, { :ok }, state }
  end

  defp pid_for(state, unit_id) do
    case HashDict.fetch(state, unit_id) do
      :error -> make_a_new_pusher(state, unit_id)
      _ -> {:ok, HashDict.fetch(state, unit_id), state}
    end
  end

  defp make_a_new_pusher(state, unit_id) do
    {:ok, pid} = IfsQ.Pusher.start
    pid_for(HashDict.put(state, unit_id, pid), unit_id)
  end

  defp dispatch(pid, message, unit_id) do
    GenServer.call(pid, {:dispatch, message, unit_id})
  end
end
