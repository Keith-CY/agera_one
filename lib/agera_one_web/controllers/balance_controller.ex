defmodule AgeraOneWeb.BalanceController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Balance

  action_fallback AgeraOneWeb.FallbackController

  def index(conn, _params) do
    balances = Chain.list_balances()
    render(conn, "index.json", balances: balances)
  end

  def create(conn, %{"balance" => balance_params}) do
    with {:ok, %Balance{} = balance} <- Chain.create_balance(balance_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", balance_path(conn, :show, balance))
      |> render("show.json", balance: balance)
    end
  end

  def show(conn, %{"id" => id}) do
    balance = Chain.get_balance!(id)
    render(conn, "show.json", balance: balance)
  end

  def update(conn, %{"id" => id, "balance" => balance_params}) do
    balance = Chain.get_balance!(id)

    with {:ok, %Balance{} = balance} <- Chain.update_balance(balance, balance_params) do
      render(conn, "show.json", balance: balance)
    end
  end

  def delete(conn, %{"id" => id}) do
    balance = Chain.get_balance!(id)
    with {:ok, %Balance{}} <- Chain.delete_balance(balance) do
      send_resp(conn, :no_content, "")
    end
  end
end
