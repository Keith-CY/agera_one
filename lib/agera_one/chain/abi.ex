defmodule AgeraOne.Chain.ABI do
  use Ecto.Schema
  import Ecto.Changeset


  schema "abis" do
    field :addr, :string
    field :content, :string
    field :number, :string

    timestamps()
  end

  @doc false
  def changeset(abi, attrs) do
    abi
    |> cast(attrs, [:addr, :content, :number])
    |> validate_required([:addr, :content, :number])
  end
end
