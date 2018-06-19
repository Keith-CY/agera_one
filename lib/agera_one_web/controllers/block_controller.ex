defmodule AgeraOneWeb.BlockController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Block

  action_fallback(AgeraOneWeb.FallbackController)

  @doc """
    Get Blocks

  ## Params
      {
        "numberFrom": "min block number", //  number or integer
        "numberTo": "max block number", // number or integer
        "transactionFrom": "min transaction count", // integer
        "transactionTo": "max transaction count", // integer
        "offset": "offset", // default to 0
        "limit": "limit", // default to 10
      }

  ## Return
      {
        "result": {
          "count": "count",
          "blocks": [
            {
              "version": 0,
              "transactionsCount": 0,
              "header": {
                "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
                "timestamp": 1529384777622,
                "stateRoot": "0x87880193218a785156835fb80e807e5d7845c15d1021dfd28153b96097ff5130",
                "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
                "proof": {
                  "Tendermint": {
                    "proposal": "0x978db6aa83074448990c97a287d8092f8c724f2f"
                  }
                },
                "prevHash": "0x784a5c68dd712c6b968b937db3b68e7726c7a42007b82ff7d8cd7a02e41a7587",
                "number": "0x31",
                "gasUsed": "0x0"
              },
              "hash": "0x87d6710d3e146f522891ec1e1731df764ddca1e407045768870bbadb54ea34ca"
            },
          ]
        }
      }
  """
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
