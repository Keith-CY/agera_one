defmodule AgeraOne.Chain.Metadata do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain

  schema "chain_metadatas" do
    field(:chain_id, :integer)
    field(:chain_name, :string)
    field(:genesis_timestamp, :utc_datetime)
    field(:operator, :string)
    field(:validators, :string)
    field(:website, :string)
    field(:number, :integer)
    field(:block_interval, :integer)
    field(:peer_count, :string)
    field(:token_name, :string)
    field(:token_symbol, :string)
    field(:token_avatar, :string)

    timestamps()
  end

  @doc false
  def changeset(metadata, attrs) do
    metadata
    |> cast(attrs |> form_attrs, [
      :chain_id,
      :chain_name,
      :genesis_timestamp,
      :operator,
      :website,
      :validators,
      :number,
      :block_interval,
      :peer_count,
      :token_name,
      :token_symbol,
      :token_avatar
    ])
    |> validate_required([
      :chain_id,
      :chain_name,
      :genesis_timestamp,
      :operator,
      :website,
      :validators,
      :number,
      :block_interval,
      :peer_count,
      :token_name,
      :token_symbol,
      :token_avatar
    ])
  end

  defp form_attrs(
         %{
           "chainId" => chain_id,
           "chainName" => chain_name,
           "genesisTimestamp" => genesis_timestamp,
           "operator" => operator,
           "validators" => validators,
           "website" => website,
           "number" => number,
           "blockInterval" => block_interval,
           "peerCount" => peer_count,
           "tokenName" => token_name,
           "tokenSymbol" => token_symbol,
           "tokenAvatar" => token_avatar
         } = attrs
       )
       when is_list(validators) do
    %{
      chain_id: chain_id,
      chain_name: chain_name,
      genesis_timestamp: genesis_timestamp |> Chain.get_time(),
      operator: operator,
      website: website,
      number: number |> Chain.hex_to_int(),
      block_interval: block_interval,
      validators: validators |> Enum.join(","),
      peer_count: peer_count,
      token_name: token_name,
      token_symbol: token_symbol,
      token_avatar: token_avatar
    }
  end
end
