defmodule AgeraOneWeb.BlockView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.{BlockView, HeaderView, TransactionView}
  # alias AgeraOne.Chain.Block

  def render("index.json", %{blocks: blocks, count: count}) do
    %{
      result: %{
        blocks: render_many(blocks, BlockView, "block.json"),
        count: count
      }
    }
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
      header: block |> render_header
    }
  end

  def render("block-transaction-hash.json", %{block: block}) do
    %{
      result: %{
        version: block.version,
        hash: block.hash,
        transactionsCount: block.transactions_count,
        header: block |> render_header,
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
        header: block |> render_header,
        body: %{
          transactions:
            render_many(block.transactions, TransactionView, "transaction-hash-content.json")
        }
      }
    }
  end

  defp render_header(block) do
    %{
      timestamp: block.timestamp |> DateTime.to_unix(:millisecond),
      prevHash: block.prev_hash,
      number: block.number |> int_to_hex(),
      stateRoot: block.state_root,
      transactionsRoot: block.transactions_root,
      receiptsRoot: block.receipts_root,
      gasUsed: block.gas_used,
      proof: %{
        Tendermint: %{
          proposal: block.proposer
        }
      }
    }
  end
end
