defmodule IfsQ.Pusher do
  use GenServer
  require Logger
  require UUID
  require IEx

  def start() do
    GenServer.start(IfsQ.Pusher, nil)
  end

  def init(_) do
    {:ok, %{id: process_identifier, status: :normal}}
  end

  def handle_cast({:dispatch, message, unit_id}, state) do
    full_message = "cast received: #{message} by: #{state.id} for #{unit_id}"
    Logger.info full_message  

    HTTPoison.post( "http://localhost:4044/event", JSX.encode!(%{message: message, unitId: unit_id}), %{"Content-Type" => "application/json"}, recv_timeout: 30000)
    |> eventer_call
    { :noreply, state }
  end

  defp eventer_call({:ok, %{status_code: code, body: body}}) when (600 > code and code >= 500) , do: IO.puts "500:  #{body}"
  defp eventer_call({:ok, response}), do: IO.puts "OK: #{response.body}"
  defp eventer_call({:error, response}), do: IO.puts "ERROR: #{response.reason}"

  defp process_identifier, do: UUID.uuid1 |> String.slice(0, 8)
end
