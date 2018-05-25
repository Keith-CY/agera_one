defmodule AgeraOne.Repo.Migrations.CreateHeaders do
  use Ecto.Migration

  def change do
    create table(:headers) do
      add(:timestamp, :utc_datetime)
      add(:prev_hash, :string)
      add(:number, :string)
      add(:state_root, :string)
      add(:transactions_root, :string)
      add(:receipts_root, :string)
      add(:gas_used, :string)
      add(:proposer, :string)
      add(:block_id, references(:blocks, on_delete: :delete_all))

      timestamps()
    end

    create(index(:headers, [:block_id, :number]))
  end
end
