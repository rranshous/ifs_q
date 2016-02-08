defmodule IfsQ.Repo.Migrations.Message do
  use Ecto.Migration

  def up do
    create table(:messages) do
      add :body,     :text
      add :shard_id, :string, size: 140
      add :sent,     :boolean, default: false

      timestamps
    end
  end

  def down do
    drop table(:messages)
  end
end
