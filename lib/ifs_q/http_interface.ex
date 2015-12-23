defmodule IfsQ.HttpInterface do
  use Plug.Router
  require IEx

  plug Plug.Parsers, parsers: [:json, :urlencoded],
                     json_decoder: JSX
  plug :match
  plug :dispatch

  post "/event" do
    message = conn.params["message"]
    unit_id = conn.params["unitId"]
    GenServer.whereis(:ifs_dispatcher)
    |> GenServer.call({:dispatch, message, unit_id})
    send_resp(conn, 200, "#{message} receieved for #{unit_id}")
  end

end
