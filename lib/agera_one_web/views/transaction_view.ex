defmodule AgeraOneWeb.TransactionView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.{TransactionView, BlockView}

  def render("count.json", %{count: count}) do
    %{
      result: count
    }
  end

  def render("index.json", %{transactions: transactions, count: count}) do
    %{
      result: %{
        transactions: render_many(transactions, TransactionView, "transaction.json"),
        count: count
      }
    }
  end

  def render("show.json", %{transaction: transaction}) do
    %{result: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction-rpc.json", %{transaction: transaction}) do
    %{
      result: render_one(transaction, TransactionView, "transaction.json")
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      hash: transaction.hash,
      content: transaction.content,
      from: transaction.from,
      to: transaction.to,
      value: ("0x" <> transaction.value) |> ExthCrypto.Math.bin_to_hex(),
      blockNumber: transaction.block_number |> int_to_hex(),
      gasUsed: transaction.gas_used,
      timestamp: transaction.block.timestamp |> DateTime.to_unix(:millisecond)
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

  def render("transaction-hash-content-rpc.json", %{transaction: transaction}) do
    %{
      result: render_one(transaction, TransactionView, "transaction-hash-content")
    }
  end

  def render("transaction-hash-content.json", %{transaction: transaction}) do
    %{
      hash: transaction.hash,
      content: transaction.content
    }
  end
end
