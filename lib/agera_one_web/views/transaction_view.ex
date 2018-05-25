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
    %{
      result: %{
        hash: transaction.hash,
        content: transaction.content
      }
    }
  end

  def render("transaction-receipt.json", %{transaction: transaction}) do
    %{
      result: %{
        transactionHash: transaction.hash,
        transactionIndex: transaction.index,
        blockHash: transaction.block_hash,
        blockNumber: transaction.block_number,
        gasUsed: transaction.gas_used,
        contractAddress: transaction.contract_address
      }
    }
  end

  def render("transaction-hash.json", %{transaction: transaction}) do
    transaction.hash
  end

  def render("transaction-hash-content.json", %{transaction: transaction}) do
    %{
      result: %{
        hash: transaction.hash,
        content: transaction.content
      }
    }
  end
end
