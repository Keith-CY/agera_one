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
      # id: header.id,
      timestamp: header.timestamp,
      prevHash: header.prev_hash,
      number: header.number,
      stateRoot: header.state_root,
      transactionsRoot: header.transactions_root,
      receiptsRoot: header.receipts_root,
      gasUsed: header.gas_used,
      proporser: header.proposer
    }
  end
end
