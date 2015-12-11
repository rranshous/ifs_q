defmodule IfsQ.HttpInterface do
  use GenServer
  use Plug.Router
  require IEx

  plug :match
  plug :dispatch

  post "/event" do
    GenServer.whereis(:ifs_dispatcher)
    |> GenServer.call({:dispatch, "greetings", 21})
    send_resp(conn, 200, "world")
  end

end
