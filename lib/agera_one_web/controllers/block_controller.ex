defmodule AgeraOneWeb.BlockController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Block

  action_fallback(AgeraOneWeb.FallbackController)

  def index(conn, params) do
    case Chain.get_blocks(%{
           number_from: params["numberFrom"],
           number_to: params["numberTo"],
           transaction_from: params["transactionFrom"],
           transaction_to: params["transactionTo"],
           offset: params["offset"] || 0,
           limit: params["limit"] || 10
         }) do
      {:ok, blocks, count} ->
        render(conn, "index.json", blocks: blocks, count: count)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def create(conn, %{"block" => block_params}) do
    with {:ok, %Block{} = block} <- Chain.create_block(block_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", block_path(conn, :show, block))
      |> render("show.json", block: block)
    end
  end

  @doc false
  def show(conn, %{"id" => id}) do
    block = Chain.get_block(id)
    render(conn, "show.json", block: block)
  end
end
