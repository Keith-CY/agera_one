defmodule AgeraOne.Repo.Migrations.CreateAbis do
  use Ecto.Migration

  def change do
    create table(:abis) do
      add :addr, :string
      add :content, :string
      add :number, :string

      timestamps()
    end

  end
end
