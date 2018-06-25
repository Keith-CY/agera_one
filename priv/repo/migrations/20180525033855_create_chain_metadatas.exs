defmodule AgeraOne.Repo.Migrations.CreateChainMetadatas do
  use Ecto.Migration

  def change do
    create table(:chain_metadatas) do
      add(:chain_id, :integer)
      add(:chain_name, :string)
      add(:genesis_timestamp, :utc_datetime)
      add(:operator, :string)
      add(:validators, :string)
      add(:website, :string)
      add(:number, :integer)
      add(:peer_count, :string)
      add(:token_name, :string)
      add(:token_symbol, :string)
      add(:token_avatar, :string)

      timestamps()
    end

    create(unique_index(:chain_metadatas, [:number]))
  end
end
