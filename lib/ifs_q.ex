# need a dispatcher
# dispatcher takes in messages from the world
# distributes messages to workers
## know which worker to send a message 
## know whether that worker is alive

# distributes messages to archiver

defmodule IfsQ do
  require IEx

  def start() do
    table = :ets.new(:unit_pid, [:named_table, :public ])
    { :ok, dispatcher_pid } = IfsQ.Dispatcher.start(:ifs_dispatcher)
    { :ok, http_interface_pid } = Plug.Adapters.Cowboy.http IfsQ.HttpInterface, [], port: 5050, ref: :ifs_dispatcher_endpoint
  end
    
  def stop() do
    Plug.Adapters.Cowboy.shutdown :ifs_dispatcher_endpoint
    :ets.delete(:unit_pid)
    GenServer.whereis(:ifs_dispatcher)
    |> GenServer.call({:kill_pids})
    GenServer.whereis(:ifs_dispatcher)
    |> Process.exit(:kill)
  end
end
