defmodule AgeraOneWeb.TransactionControllerTest do
  use AgeraOneWeb.ConnCase

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Transaction

  @create_attrs %{content: "some content", hash: "some hash"}
  @update_attrs %{content: "some updated content", hash: "some updated hash"}
  @invalid_attrs %{content: nil, hash: nil}

  def fixture(:transaction) do
    {:ok, transaction} = Chain.create_transaction(@create_attrs)
    transaction
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      conn = get conn, transaction_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn} do
      conn = post conn, transaction_path(conn, :create), transaction: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, transaction_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "content" => "some content",
        "hash" => "some hash"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, transaction_path(conn, :create), transaction: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update transaction" do
    setup [:create_transaction]

    test "renders transaction when data is valid", %{conn: conn, transaction: %Transaction{id: id} = transaction} do
      conn = put conn, transaction_path(conn, :update, transaction), transaction: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, transaction_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "content" => "some updated content",
        "hash" => "some updated hash"}
    end

    test "renders errors when data is invalid", %{conn: conn, transaction: transaction} do
      conn = put conn, transaction_path(conn, :update, transaction), transaction: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete transaction" do
    setup [:create_transaction]

    test "deletes chosen transaction", %{conn: conn, transaction: transaction} do
      conn = delete conn, transaction_path(conn, :delete, transaction)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, transaction_path(conn, :show, transaction)
      end
    end
  end

  defp create_transaction(_) do
    transaction = fixture(:transaction)
    {:ok, transaction: transaction}
  end
end
