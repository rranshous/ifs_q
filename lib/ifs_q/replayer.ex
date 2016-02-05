# This is the replayer
# The replayer takes messages from the database and sends them to workers and archivers

defmodule IfsQ.Replayer do
  import Ecto.Query, only: [from: 2]

  def replay do
    dispatcher = GenServer.whereis(:ifs_dispatcher)
    query = from m in IfsQ.Message,
              where: m.sent == false,
              order_by: m.id
    IfsQ.Repo.all(query)
    |> Enum.each(fn(m) -> GenServer.call(dispatcher, 
                                        {:dispatch, m.body, m.shard_id, m.id})
                          end)
  end

end
