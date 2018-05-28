defmodule AgeraOne.Chain.ABI do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain

  schema "abis" do
    field(:addr, :string)
    field(:content, :string)
    field(:number, :integer)

    timestamps()
  end

  @doc false
  def changeset(abi, attrs) do
    abi
    |> cast(%{attrs | "number" => attrs["number"] |> Chain.hex_to_int()}, [
      :addr,
      :content,
      :number
    ])
    |> validate_required([:addr, :content, :number])
  end
end
