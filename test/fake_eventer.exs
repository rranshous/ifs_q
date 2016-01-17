defmodule FakeEventer do
  use Plug.Router
  require IEx

  plug Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: JSX
  plug :match
  plug :dispatch

  @port Application.get_env(:ifs_q, :eventer_port)
  get "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/event" do
    IO.puts("UNIT ID: #{conn.params["unitId"]}")
    send_rand_resp(conn)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  def send_rand_resp conn do
    :random.seed(:os.timestamp)
    case :random.uniform(4) do
      1 -> :timer.sleep(20000)
           send_resp(conn, 200, "long event! for #{conn.params["unitId"]}")
      2 -> send_resp(conn, 500, "five oh oh for #{conn.params["unitId"]}")
      3 -> send_resp(conn, 404, "Resource not found for #{conn.params["unitId"]}")
      4 -> send_resp(conn, 200, "event! for #{conn.params["unitId"]}")
    end
  end

  def start do
    IO.puts "PORT: #{@port}"
    Plug.Adapters.Cowboy.http FakeEventer, [], port: @port, ref: :eventer
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown :eventer
  end
end
