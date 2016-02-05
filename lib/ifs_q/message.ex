defmodule IfsQ.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body,      :string
    field :shard_id, :string
    field :sent,     :boolean, default: false
  end
end
