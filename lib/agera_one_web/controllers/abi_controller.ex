defmodule AgeraOneWeb.ABIController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain
  alias AgeraOne.Chain.ABI

  action_fallback AgeraOneWeb.FallbackController

  def index(conn, _params) do
    abis = Chain.list_abis()
    render(conn, "index.json", abis: abis)
  end

  def create(conn, %{"abi" => abi_params}) do
    with {:ok, %ABI{} = abi} <- Chain.create_abi(abi_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", abi_path(conn, :show, abi))
      |> render("show.json", abi: abi)
    end
  end

  def show(conn, %{"id" => id}) do
    abi = Chain.get_abi!(id)
    render(conn, "show.json", abi: abi)
  end

  def update(conn, %{"id" => id, "abi" => abi_params}) do
    abi = Chain.get_abi!(id)

    with {:ok, %ABI{} = abi} <- Chain.update_abi(abi, abi_params) do
      render(conn, "show.json", abi: abi)
    end
  end

  def delete(conn, %{"id" => id}) do
    abi = Chain.get_abi!(id)
    with {:ok, %ABI{}} <- Chain.delete_abi(abi) do
      send_resp(conn, :no_content, "")
    end
  end
end
