defmodule AgeraOneWeb.MetadataView do
  use AgeraOneWeb, :view

  def render("peer_count.json", %{peer_count: peer_count}) do
    %{
      result: peer_count
    }
  end

  def render("metadata.json", %{metadata: metadata}) do
    %{
      result: %{
        chainId: metadata.chain_id,
        chainName: metadata.chain_name,
        operator: metadata.operator,
        validators: metadata.validators |> String.split(","),
        website: metadata.website,
        genesisTimestamp: metadata.genesis_timestamp |> DateTime.to_unix(:millisecond),
        number: metadata.number |> int_to_hex(),
        tokenName: metadata.token_name,
        tokenSymbol: metadata.token_symbol,
        tokenAvatar: metadata.token_avatar
      }
    }
  end
end
