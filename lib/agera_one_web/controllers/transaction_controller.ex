defmodule AgeraOneWeb.TransactionController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Transaction

  action_fallback(AgeraOneWeb.FallbackController)

  def index(conn, params) do
    case Chain.get_transactions(%{
           account: params["account"],
           from: params["from"],
           to: params["to"],
           value_from: params["value_from"],
           value_to: params["value_to"],
           offset: params["offset"] || 0,
           limit: params["limit"] || 10
         }) do
      {:ok, transactions, count} ->
        render(conn, "index.json", transactions: transactions, count: count)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <- Chain.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Chain.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Chain.get_transaction!(id)

    with {:ok, %Transaction{} = transaction} <-
           Chain.update_transaction(transaction, transaction_params) do
      render(conn, "show.json", transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Chain.get_transaction!(id)

    with {:ok, %Transaction{}} <- Chain.delete_transaction(transaction) do
      send_resp(conn, :no_content, "")
    end
  end
end
