defmodule AgeraOneWeb.HeaderView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.HeaderView

  def render("index.json", %{headers: headers}) do
    %{data: render_many(headers, HeaderView, "header.json")}
  end

  def render("show.json", %{header: header}) do
    %{data: render_one(header, HeaderView, "header.json")}
  end

  def render("header.json", %{header: header}) do
    %{
      timestamp: header.timestamp |> DateTime.to_unix(:millisecond),
      prevHash: header.prev_hash,
      number: header.number |> int_to_hex(),
      stateRoot: header.state_root,
      transactionsRoot: header.transactions_root,
      receiptsRoot: header.receipts_root,
      gasUsed: header.gas_used,
      proof: %{
        Tendermint: %{
          proposal: header.proposer
        }
      }
    }
  end
end
