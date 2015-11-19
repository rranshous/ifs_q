# This is the dispatcher
# The dispatcher takes messages from the outside world and sends them to workers and archivers

defmodule IfsQ.Dispatcher do
  use GenServer

  def start() do
    GenServer.start(IfsQ.Dispatcher, nil)
  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def handle_call({:dispatch, message, unit_id}, _, state) do
    pid_for(state, unit_id)
  end

  defp pid_for(state, unit_id) do
    case HashDict.fetch(state, unit_id) do
      :error -> pid_for(HashDict.put(state, unit_id, "hello #{unit_id}"), unit_id)
      _ -> {:reply, HashDict.fetch(state, unit_id), state}
    end
  end
end
