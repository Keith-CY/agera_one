defmodule AgeraOne.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :addr, :string
      add :value, :string
      add :number, :integer

      timestamps()
    end

  end
end
