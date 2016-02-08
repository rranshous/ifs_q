defmodule IfsQ.HttpInterface do
  use Plug.Router
  require IEx

  plug :match
  plug :dispatch

  post "/event" do
    shard_id = Map.new(conn.req_headers)["jmsxgroupid"]
    {:ok, message, _} = Plug.Conn.read_body(conn)
    IfsQ.DataDealer.record(message, shard_id)
    send_resp(conn, 200, "#{message} receieved for #{shard_id}")
  end

end
