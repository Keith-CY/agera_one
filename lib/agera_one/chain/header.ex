defmodule AgeraOne.Chain.Header do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain
  alias AgeraOne.Chain.Block

  schema "headers" do
    field(:gas_used, :string)
    field(:number, :integer)
    field(:prev_hash, :string)
    field(:proposer, :string)
    field(:receipts_root, :string)
    field(:state_root, :string)
    field(:timestamp, :utc_datetime)
    field(:transactions_root, :string)
    belongs_to(:block, Block)

    timestamps()
  end

  @doc false
  def changeset(header, attrs) do
    header
    |> cast(%{attrs | "number" => attrs["number"] |> Chain.hex_to_int()}, [
      :timestamp,
      :prev_hash,
      :number,
      :state_root,
      :transactions_root,
      :receipts_root,
      :gas_used,
      :proposer
    ])
    |> validate_required([
      :timestamp,
      :prev_hash,
      :number,
      :state_root,
      :transactions_root,
      :receipts_root,
      :gas_used,
      :proposer
    ])
    |> unique_constraint(:number)
  end
end
