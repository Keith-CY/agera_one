defmodule AgeraOne.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add(:version, :integer)
      add(:hash, :string)
      add(:transactions_count, :integer)

      add(:timestamp, :utc_datetime)
      add(:prev_hash, :string)
      add(:number, :integer)
      add(:state_root, :string)
      add(:transactions_root, :string)
      add(:receipts_root, :string)
      add(:gas_used, :string)
      add(:proposer, :string)

      timestamps()
    end

    create(unique_index(:blocks, :hash))
  end
end
