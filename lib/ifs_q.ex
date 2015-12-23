# need a dispatcher
# dispatcher takes in messages from the world
# distributes messages to workers
## know which worker to send a message 
## know whether that worker is alive

# distributes messages to archiver

defmodule IfsQ do
  def start() do
    { :ok, dispatcher_pid } = IfsQ.Dispatcher.start(:ifs_dispatcher)
    { :ok, http_interface_pid } = Plug.Adapters.Cowboy.http IfsQ.HttpInterface, [], port: 5050, ref: :ifs_dispatcher_endpoint
  end
    
end
