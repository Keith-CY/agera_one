defmodule AgeraOneWeb.BlockController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Block

  action_fallback(AgeraOneWeb.FallbackController)

  @doc false
  def index(conn, _params) do
    blocks = Chain.list_page_blocks()
    render(conn, "index.json", blocks: blocks)
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

  @doc false
  def query_block(_conn, %{hash: hash}) do
    Chain.get_block(%{hash: hash})
  end

  @doc false
  def query_block(_conn, %{height: height}) do
    Chain.get_block(%{number: height})
  end
end
