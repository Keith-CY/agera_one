defmodule AgeraOneWeb.TransactionController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Transaction

  action_fallback(AgeraOneWeb.FallbackController)

  @doc """
    Get transactions

  ## Params
      {
        "account":  "the addr transactions related to", // hash
        "from":  "the addr transactions from", // hash
        "to":  "the addr transactions to", // hash
        "valueFrom":  "min value", // integer
        "valueTo":  "max value", // integer
        "offset":  "offset", // default to 0
        "limit":  "limit", // default to 10
      }

  ## Return
      {
        "result": {
          "count": count,
          "transactions": [
            "value": null,
            "to": null,
            "timestamp": 1529379404666,
            "hash": "0x760f07bc5482f3a084f5031da0d2794ddd0c4913dc9617005966ff9ed3425f10",
            "gasUsed": "0x0",
            "from": "0xd5ec01b4f7d8206bf01002d820ff54a0b8d9399d",
            "content": "0x0a1e186420bec3082a14627306090abab3a6e1400e9345bc60c78a8bef57380112410c68ec726f98a65ea766ad0700da48a596031ed52c286e0b8b7ca662308b61cb1ff9443dc9152e0071e24970fff7dec20431fa0a6663f43bdbf519f0ee4ae82501",
            "blockNumber": "0x22169"
          ]
        }
      }
  """
  def index(conn, params) do
    case Chain.get_transactions(%{
           account: params["account"],
           from: params["from"],
           to: params["to"],
           value_from: params["valueFrom"],
           value_to: params["valueTo"],
           offset: params["offset"] || 0,
           limit: params["limit"] || 10
         }) do
      {:ok, transactions, count} ->
        render(conn, "index.json", transactions: transactions, count: count)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <- Chain.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  @doc false
  def show(conn, %{"id" => id}) do
    transaction = Chain.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end

  @doc false
  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Chain.get_transaction!(id)

    with {:ok, %Transaction{} = transaction} <-
           Chain.update_transaction(transaction, transaction_params) do
      render(conn, "show.json", transaction: transaction)
    end
  end

  @doc false
  def delete(conn, %{"id" => id}) do
    transaction = Chain.get_transaction!(id)

    with {:ok, %Transaction{}} <- Chain.delete_transaction(transaction) do
      send_resp(conn, :no_content, "")
    end
  end
end
