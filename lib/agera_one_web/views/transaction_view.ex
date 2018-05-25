defmodule AgeraOneWeb.TransactionView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    # %{block: %{hash: hash}} = transaction
    %{
      hash: transaction.hash,
      content: transaction.content
    }
  end

  def render("transaction-hash.json", %{transaction: transaction}) do
    transaction.hash
  end

  def render("transaction-hash-content.json", %{transaction: transaction}) do
    %{
      hash: transaction.hash,
      content: transaction.content
    }
  end
end
