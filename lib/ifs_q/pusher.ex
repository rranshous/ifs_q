defmodule IfsQ.Pusher do
  use GenServer

  def start() do
    HTTPotion.start
    GenServer.start(IfsQ.Pusher, nil)
  end

  def init(_) do
    {:ok, :os.timestamp |> Tuple.to_list |> List.last }
  end

  def handle_cast({:dispatch, message, unit_id}, state) do
    full_message = "cast: #{message} by: #{state} for #{unit_id}"
    IO.puts full_message
    HTTPotion.post "http://localhost:4000/receive", [body: full_message, headers: []]
    { :noreply, state }
  end

  def handle_call({:dispatch, message, unit_id}, _, state) do
    #IO.puts self
    IO.puts "call: #{message} by: #{state} for #{unit_id}"
    IO.puts message
    {:reply, { self, "received #{message} for #{unit_id}" }, state}
  end
end
