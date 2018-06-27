defmodule AgeraOne.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:hash, :string)
      add(:content, :text)
      add(:block_hash, :string)
      add(:block_number, :integer)
      add(:contract_address, :string)
      add(:gas_used, :string)
      add(:index, :string)
      add(:from, :string)
      add(:to, :string)
      add(:data, :binary)
      add(:value, :bigint)
      add(:block_id, references(:blocks, on_delete: :delete_all))

      timestamps()
    end

    create(index(:transactions, [:block_id, :block_hash]))
  end
end
