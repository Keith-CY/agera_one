defmodule AgeraOne.Repo.Migrations.CreateAbis do
  use Ecto.Migration

  def change do
    create table(:abis) do
      add(:addr, :string)
      add(:content, :text)
      add(:number, :integer)

      timestamps()
    end
  end
end
