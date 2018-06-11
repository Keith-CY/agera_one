defmodule AgeraOneWeb.BlockView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.{BlockView, HeaderView, TransactionView}
  # alias AgeraOne.Chain.Block

  def render("index.json", %{blocks: blocks}) do
    %{result: render_many(blocks, BlockView, "block.json")}
  end

  def render("show.json", %{block: block}) do
    %{result: render_one(block, BlockView, "block.json")}
  end

  def render("block_number.json", %{number: number}) do
    %{result: number}
  end

  def render("block.json", %{block: block}) do
    %{
      version: block.version,
      hash: block.hash,
      transactionsCount: block.transactions_count,
      header: HeaderView.render("header.json", %{header: block.header})
    }
  end

  def render("block-transaction-hash.json", %{block: block}) do
    %{
      result: %{
        version: block.version,
        hash: block.hash,
        transactionsCount: block.transactions_count,
        header: HeaderView.render("header.json", %{header: block.header}),
        body: %{
          transactions: render_many(block.transactions, TransactionView, "transaction-hash.json")
        }
      }
    }
  end

  def render("block-transaction-hash-content.json", %{block: block}) do
    %{
      result: %{
        version: block.version,
        hash: block.hash,
        transactionsCount: block.transactions_count,
        header: HeaderView.render("header.json", %{header: block.header}),
        body: %{
          transactions:
            render_many(block.transactions, TransactionView, "transaction-hash-content.json")
        }
      }
    }
  end
end
