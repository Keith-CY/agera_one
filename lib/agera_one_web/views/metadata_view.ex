defmodule AgeraOneWeb.MetadataView do
  use AgeraOneWeb, :view

  def render("metadata.json", %{metadata: metadata}) do
    %{
      chainId: metadata.chain_id,
      chainName: metadata.chain_name,
      operator: metadata.operator,
      validators: metadata.validators |> String.split(),
      website: metadata.website,
      genesisTimestamp: metadata.genesis_timestamp,
      number: metadata.number
    }
  end
end
