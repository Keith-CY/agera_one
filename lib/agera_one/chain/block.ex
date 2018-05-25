defmodule AgeraOne.Chain.Block do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain.{Header, Transaction}

  schema "blocks" do
    field(:hash, :string)
    field(:version, :integer)
    field(:transactions_count, :integer)
    has_one(:header, Header)
    has_many(:transactions, Transaction)

    timestamps()
  end

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, [:version, :hash, :transactions_count])
    |> validate_required([:version, :hash])
    |> unique_constraint(:hash)
  end
end
