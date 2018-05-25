defmodule AgeraOne.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add(:version, :integer)
      add(:hash, :string)
      add(:transactions_count, :integer)

      timestamps()
    end

    create(unique_index(:blocks, :hash))
  end
end
