defmodule AgeraOne.Chain.Block do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain.Transaction

  schema "blocks" do
    field(:hash, :string)
    field(:version, :integer)
    field(:transactions_count, :integer)
    field(:gas_used, :string)
    field(:number, :integer)
    field(:prev_hash, :string)
    field(:proposer, :string)
    field(:receipts_root, :string)
    field(:state_root, :string)
    field(:timestamp, :utc_datetime)
    field(:transactions_root, :string)
    has_many(:transactions, Transaction)

    timestamps()
  end

  @doc false
  def changeset(block, block_attrs) do
    block
    |> cast(block_attrs, [
      :version,
      :hash,
      :transactions_count,
      :gas_used,
      :number,
      :prev_hash,
      :proposer,
      :receipts_root,
      :state_root,
      :timestamp,
      :transactions_root
    ])
    |> validate_required([:version, :hash])
    |> unique_constraint(:hash)
  end
end
