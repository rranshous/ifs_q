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

  def handle_cast({:dispatch, message, unit_id, message_id}, state) do
    Logger.info  "cast received: #{message} by: #{state.id} for #{unit_id}"

    call_eventer(message, unit_id)
    mark_sent(message_id)
    { :noreply, state }
  end

  defp call_eventer(message, unit_id) do
    HTTPoison.post( "#{eventer_url}/event",
                    JSX.encode!(%{message: message, unitId: unit_id}), 
                    %{"Content-Type" => "text/plain",
                      "JMSXGroupID" => unit_id},
                    recv_timeout: 50)
    |> eventer_call(message, unit_id)
  end

  defp eventer_call({:ok, %{status_code: code, body: body}}, message, unit_id) when (600 > code and code >= 500) do
    Logger.info "#{code}:  #{body} by #{registered_name}"
    call_eventer(message, unit_id)
  end
  defp eventer_call({:ok, %{status_code: code, body: body}}, _, _) when (500 > code and code >= 400) do
    Logger.info "#{code}: #{body} by #{registered_name}"
  end

  defp eventer_call({:ok, %{status_code: code, body: body}}, _, _) when (400 > code and code >= 300), do: Logger.info "#{code}: #{body} by #{registered_name}"
  defp eventer_call({:ok, %{status_code: code, body: body}}, _, _) when (300 > code and code >= 200), do: Logger.info "OK: #{body} by #{registered_name}"
  defp eventer_call({:error, response}, message, unit_id) do
    Logger.info "ERROR: #{response.reason} by #{registered_name}"
    call_eventer(message, unit_id)
  end

  defp registered_name, do: Process.info(self)[:registered_name]

  defp eventer_url, do: Application.get_env(:ifs_q, IfsQ)[:eventer_url]

  defp mark_sent message_id do
    IfsQ.Repo.get(IfsQ.Message, message_id)
    |> Ecto.Changeset.change(sent: true)
    |> IfsQ.Repo.update
  end
end
