defmodule AgeraOneWeb.RpcController do
  use AgeraOneWeb, :controller
  alias AgeraOne.Chain
  alias AgeraOne.Repo
  alias AgeraOne.Chain.{Message, Block, Transaction, Metadata}
  alias AgeraOneWeb.{BlockView, TransactionView, MetadataView}

  action_fallback(AgeraOneWeb.FallbackController)

  @doc false
  def index(conn, %{"method" => "cita_getMetaData", "params" => [number]}) do
    case Chain.get_metadata(number) do
      {:ok, %Metadata{} = metadata} ->
        conn |> render(MetadataView, "metadata.json", metadata: metadata)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def index(conn, %{"method" => "cita_blockNumber"}) do
    number = Chain.get_latest_block_header() |> Map.get(:number)

    conn
    |> render(BlockView, "block_number.json", number: number)
  end

  @doc false
  def index(conn, %{"method" => "cita_getTransaction", "params" => [hash]}) do
    case Chain.get_transaction(%{hash: hash}) do
      {:ok, %Transaction{} = transaction} ->
        conn
        |> render(TransactionView, "transaction.json", transaction: transaction)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false

  def index(conn, %{"method" => "cita_getTransactionReceipt", "params" => [hash]}) do
    case Chain.get_transaction(%{hash: hash}) do
      {:ok, %Transaction{} = transaction} ->
        conn
        |> render(TransactionView, "transaction-receipt.json", transaction: transaction)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def index(conn, %{"method" => "cita_getTransactionReceipt", "params" => [hash]}) do
    case Chain.get_transaction(%{hash: hash}) do
      {:ok, %Transaction{} = transaction} ->
        conn
        |> render(TransactionView, "transaction.json", transaction: transaction)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def index(conn, %{"method" => "cita_getBlockByNumber", "params" => [number, detailed]}) do
    block = get_block_by(%{number: number})

    render_block(conn, block, detailed)
  end

  @doc false
  def index(conn, %{"method" => "cita_getBlockByHash", "params" => [hash, detailed]}) do
    block = get_block_by(%{hash: hash})

    render_block(conn, block, detailed)
  end

  @doc false
  defp get_block_by(params) do
    case Chain.get_block(params) do
      {:ok, %Block{} = block} ->
        block |> Repo.preload([:transactions])

      error ->
        IO.inspect(error)
        error
    end
  end

  @doc false
  defp render_block(conn, block, detailed \\ false) do
    case detailed do
      false ->
        conn |> render(BlockView, "block-transaction-hash.json", block: block)

      _ ->
        conn |> render(BlockView, "block-transaction-hash-content.json", block: block)
    end
  end

  @doc false
  def index(conn, _) do
    # rende
  end
end
