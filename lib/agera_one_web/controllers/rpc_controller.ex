defmodule AgeraOneWeb.RpcController do
  use AgeraOneWeb, :controller
  alias AgeraOne.Chain
  alias AgeraOne.Repo
  alias AgeraOne.Chain.{Message, Block, Transaction}
  alias AgeraOneWeb.{BlockView, TransactionView}

  action_fallback(AgeraOneWeb.FallbackController)

  def index(conn, %{"method" => "cita_getBlockByNumber", "params" => [number, detailed]}) do
    # block =
    #   case Chain.get_block(%{number: number}) do
    #     {:ok, %Block{} = block} ->
    #       block |> Repo.preload([:transactions])

    #     error ->
    #       IO.inspect(error)
    #       error
    #   end
    block = get_block_by(%{number: number})

    render_block(conn, block, detailed)
  end

  def index(conn, %{"method" => "cita_getBlockByHash", "params" => [hash, detailed]}) do
    block = get_block_by(%{hash: hash})

    render_block(conn, block, detailed)
  end

  defp get_block_by(params) do
    case Chain.get_block(params) do
      {:ok, %Block{} = block} ->
        block |> Repo.preload([:transactions])

      error ->
        IO.inspect(error)
        error
    end
  end

  defp render_block(conn, block, detailed \\ false) do
    case detailed do
      false ->
        conn |> render(BlockView, "block-transaction-hash.json", block: block)

      _ ->
        conn |> render(BlockView, "block-transaction-hash-content.json", block: block)
    end
  end

  def index(conn, _) do
    # rende
  end
end
