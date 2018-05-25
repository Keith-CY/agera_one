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
    field(:number, :string)

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
      :number
    ])
    |> validate_required([
      :chain_id,
      :chain_name,
      :genesis_timestamp,
      :operator,
      :website,
      :validators,
      :number
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
           "number" => number
         } = attrs
       )
       when is_list(validators) do
    %{
      chain_id: chain_id,
      chain_name: chain_name,
      genesis_timestamp: genesis_timestamp |> Chain.get_time(),
      operator: operator,
      website: website,
      number: number,
      validators: validators |> Enum.join()
    }
  end
end
