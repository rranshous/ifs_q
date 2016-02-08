defmodule IfsQ do
  require IEx

  @port Application.get_env(:ifs_q, IfsQ)[:dispatch_port]

  def start() do
    IfsQ.Repo.start_link
    { :ok, _dispatcher_pid } = IfsQ.Dispatcher.start(:ifs_dispatcher)
    IfsQ.DataDealer.replay
    { :ok, _http_interface_pid } = Plug.Adapters.Cowboy.http IfsQ.HttpInterface, [], port: @port, ref: :ifs_dispatcher_endpoint
  end
    
  def stop() do
    Plug.Adapters.Cowboy.shutdown :ifs_dispatcher_endpoint
    pid = GenServer.whereis(:ifs_dispatcher)
    GenServer.call(pid, {:kill_pids})
    Process.exit(pid, :kill)
  end

end
