defmodule IfsQ.Pusher do
  use GenServer

  def start() do
    GenServer.start(IfsQ.Pusher, nil)
  end

  def init(_) do
    {:ok, :os.timestamp |> Tuple.to_list |> List.last }
  end

  def handle_cast({:dispatch, message, unit_id}, state) do
    IO.puts "cast: #{message} by: #{state} for #{unit_id}"
    { :noreply, state }
  end

  def handle_call({:dispatch, message, unit_id}, _, state) do
    #IO.puts self
    IO.puts "call: #{message} by: #{state} for #{unit_id}"
    IO.puts message
    {:reply, { self, "received #{message} for #{unit_id}" }, state}
  end
end
