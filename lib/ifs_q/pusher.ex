defmodule IfsQ.Pusher do
  use GenServer
  require Logger
  require UUID
  require IEx


  def start(name) do
    GenServer.start(IfsQ.Pusher, nil, name: name)
  end

  def init(_) do
    {:ok, %{id: Process.info(self)[:registered_name], status: :normal}}
  end

  def handle_cast({:dispatch, _message, _unit_id}, %{id: _id, status: :logging}) do
  end

  def handle_cast({:dispatch, message, unit_id}, state) do
    Logger.info  "cast received: #{message} by: #{state.id} for #{unit_id}"

    HTTPoison.post( "#{eventer_url}/event", JSX.encode!(%{message: message, unitId: unit_id}), %{"Content-Type" => "application/text", "JMSXGroupID" => unit_id}, recv_timeout: 30000)
    |> eventer_call
    { :noreply, state }
  end

  defp eventer_call({:ok, %{status_code: code, body: body}}) when (600 > code and code >= 500) do
    Logger.info "#{code}:  #{body} by #{registered_name}"
  end
  defp eventer_call({:ok, %{status_code: code, body: body}}) when (500 > code and code >= 400), do: Logger.info "#{code}: #{body} by #{registered_name}"
  defp eventer_call({:ok, %{status_code: code, body: body}}) when (400 > code and code >= 300), do: Logger.info "#{code}: #{body} by #{registered_name}"
  defp eventer_call({:ok, %{status_code: code, body: body}}) when (300 > code and code >= 200), do: Logger.info "OK: #{body} by #{registered_name}"
  defp eventer_call({:error, response}), do: Logger.info "ERROR: #{response.reason} by #{registered_name}"

  defp registered_name, do: Process.info(self)[:registered_name]

  defp eventer_url, do: Application.get_env(:ifs_q, IfsQ)[:eventer_url]
end
