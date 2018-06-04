defmodule AgeraOneWeb.TransactionView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.{TransactionView, BlockView}

  def render("count.json", %{count: count}) do
    %{
      result: count
    }
  end

  def render("index.json", %{transactions: transactions}) do
    %{result: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{result: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    IO.inspect(transaction.block.header)

    %{
      hash: transaction.hash,
      content: transaction.content,
      from: transaction.from,
      to: transaction.to,
      value: transaction.value,
      blockNumber: transaction.block_number |> int_to_hex(),
      gasUsed: transaction.gas_used,
      timestamp: transaction.block.header.timestamp |> DateTime.to_unix()
    }
  end

  def render("transaction-receipt.json", %{transaction: transaction}) do
    %{
      result: %{
        transactionHash: transaction.hash,
        transactionIndex: transaction.index,
        blockHash: transaction.block_hash,
        blockNumber: transaction.block_number |> int_to_hex(),
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
