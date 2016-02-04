# need a dispatcher
# dispatcher takes in messages from the world
# distributes messages to workers
## know which worker to send a message 
## know whether that worker is alive

# distributes messages to archiver

defmodule IfsQ do
  require IEx

  @port Application.get_env(:ifs_q, IfsQ)[:dispatch_port]

  def start() do
    { :ok, dispatcher_pid } = IfsQ.Dispatcher.start(:ifs_dispatcher)
    { :ok, http_interface_pid } = Plug.Adapters.Cowboy.http IfsQ.HttpInterface, [], port: @port, ref: :ifs_dispatcher_endpoint
  end
    
  def stop() do
    Plug.Adapters.Cowboy.shutdown :ifs_dispatcher_endpoint
    pid = GenServer.whereis(:ifs_dispatcher)
    GenServer.call(pid, {:kill_pids})
    Process.exit(pid, :kill)
  end

end
