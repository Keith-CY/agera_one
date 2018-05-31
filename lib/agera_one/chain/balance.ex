defmodule AgeraOne.Chain.Balance do
  use Ecto.Schema
  import Ecto.Changeset
  alias AgeraOne.Chain

  schema "balances" do
    field(:addr, :string)
    field(:value, :string)
    field(:number, :integer)

    timestamps()
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs |> formatter, [:addr, :value, :number])
    |> validate_required([:addr, :value, :number])
    |> unique_constraint(:addr)
  end

  defp formatter(attr) do
    %{attr | number: attr.number |> Chain.hex_to_int()}
  end
end
