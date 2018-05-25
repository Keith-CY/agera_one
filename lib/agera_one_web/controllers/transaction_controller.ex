defmodule AgeraOneWeb.TransactionController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Transaction

  action_fallback(AgeraOneWeb.FallbackController)

  def index(conn, _params) do
    transactions = Chain.list_page_transactions(10, 10)
    render(conn, "index.json", transactions: transactions)
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
