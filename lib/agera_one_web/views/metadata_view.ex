defmodule AgeraOneWeb.MetadataView do
  use AgeraOneWeb, :view

  def render("peer_count.json", %{peer_count: peer_count}) do
    %{
      result: peer_count
    }
  end

  def render("metadata.json", %{metadata: metadata}) do
    %{
      chainId: metadata.chain_id,
      chainName: metadata.chain_name,
      operator: metadata.operator,
      validators: metadata.validators |> String.split(),
      website: metadata.website,
      genesisTimestamp: metadata.genesis_timestamp,
      number: metadata.number |> int_to_hex()
    }
  end
end
