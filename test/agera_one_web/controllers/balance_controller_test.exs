defmodule AgeraOneWeb.BalanceControllerTest do
  use AgeraOneWeb.ConnCase

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Balance

  @create_attrs %{addr: "some addr", balance: "some balance", number: 42}
  @update_attrs %{addr: "some updated addr", balance: "some updated balance", number: 43}
  @invalid_attrs %{addr: nil, balance: nil, number: nil}

  def fixture(:balance) do
    {:ok, balance} = Chain.create_balance(@create_attrs)
    balance
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all balances", %{conn: conn} do
      conn = get conn, balance_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create balance" do
    test "renders balance when data is valid", %{conn: conn} do
      conn = post conn, balance_path(conn, :create), balance: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, balance_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "addr" => "some addr",
        "balance" => "some balance",
        "number" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, balance_path(conn, :create), balance: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update balance" do
    setup [:create_balance]

    test "renders balance when data is valid", %{conn: conn, balance: %Balance{id: id} = balance} do
      conn = put conn, balance_path(conn, :update, balance), balance: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, balance_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "addr" => "some updated addr",
        "balance" => "some updated balance",
        "number" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      conn = put conn, balance_path(conn, :update, balance), balance: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete balance" do
    setup [:create_balance]

    test "deletes chosen balance", %{conn: conn, balance: balance} do
      conn = delete conn, balance_path(conn, :delete, balance)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, balance_path(conn, :show, balance)
      end
    end
  end

  defp create_balance(_) do
    balance = fixture(:balance)
    {:ok, balance: balance}
  end
end
