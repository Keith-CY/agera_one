defmodule AgeraOne.Chain.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain
  alias AgeraOne.Chain.Block
  alias AgeraOne.Chain.Message

  schema "transactions" do
    field(:content, :string)
    field(:hash, :string)
    field(:block_hash, :string)
    field(:block_number, :integer)
    field(:contract_address, :string)
    field(:gas_used, :string)
    field(:index, :string)
    field(:from, :string)
    field(:to, :string)
    field(:data, :binary)
    field(:value, :binary)
    belongs_to(:block, Block)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> Map.put(:block_number, transaction.block_number |> Chain.hex_to_int())
    |> add_transaction_detail
    |> cast(attrs, [
      :hash,
      :content,
      :block_hash,
      :block_number,
      :contract_address,
      :gas_used,
      :index
    ])
    |> validate_required([:hash])
    |> unique_constraint(:hash)
  end

  def add_transaction_detail(transaction) do
    {:ok, sig, tx} = Message.parse_unverified_transaction(transaction.content)
    {:ok, from} = Message.get_from(transaction.content)

    tx_detail =
      case(tx) do
        %{
          data: data,
          nonce: nonce,
          valid_until_block: valid_until_block,
          to: to,
          value: value
        } ->
          if is_nil(to) do
            to = "0x" <> to
          end

          %{
            to: to,
            nonce: nonce,
            data: data,
            valid_until_block: valid_until_block,
            from: from,
            value: value
          }

        tx ->
          tx
      end

    transaction
    |> cast(tx_detail, [:to, :data, :from, :value])
  end
end
