defmodule AgeraOneWeb.HeaderControllerTest do
  use AgeraOneWeb.ConnCase

  alias AgeraOne.Chain
  alias AgeraOne.Chain.Header

  @create_attrs %{gas_used: "some gas_used", number: "some number", prev_hash: "some prev_hash", proporser: "some proporser", receipts_root: "some receipts_root", state_root: "some state_root", timestamp: ~D[2010-04-17], transactions_root: "some transactions_root"}
  @update_attrs %{gas_used: "some updated gas_used", number: "some updated number", prev_hash: "some updated prev_hash", proporser: "some updated proporser", receipts_root: "some updated receipts_root", state_root: "some updated state_root", timestamp: ~D[2011-05-18], transactions_root: "some updated transactions_root"}
  @invalid_attrs %{gas_used: nil, number: nil, prev_hash: nil, proporser: nil, receipts_root: nil, state_root: nil, timestamp: nil, transactions_root: nil}

  def fixture(:header) do
    {:ok, header} = Chain.create_header(@create_attrs)
    header
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all headers", %{conn: conn} do
      conn = get conn, header_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create header" do
    test "renders header when data is valid", %{conn: conn} do
      conn = post conn, header_path(conn, :create), header: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, header_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "gas_used" => "some gas_used",
        "number" => "some number",
        "prev_hash" => "some prev_hash",
        "proporser" => "some proporser",
        "receipts_root" => "some receipts_root",
        "state_root" => "some state_root",
        "timestamp" => ~D[2010-04-17],
        "transactions_root" => "some transactions_root"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, header_path(conn, :create), header: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update header" do
    setup [:create_header]

    test "renders header when data is valid", %{conn: conn, header: %Header{id: id} = header} do
      conn = put conn, header_path(conn, :update, header), header: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, header_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "gas_used" => "some updated gas_used",
        "number" => "some updated number",
        "prev_hash" => "some updated prev_hash",
        "proporser" => "some updated proporser",
        "receipts_root" => "some updated receipts_root",
        "state_root" => "some updated state_root",
        "timestamp" => ~D[2011-05-18],
        "transactions_root" => "some updated transactions_root"}
    end

    test "renders errors when data is invalid", %{conn: conn, header: header} do
      conn = put conn, header_path(conn, :update, header), header: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete header" do
    setup [:create_header]

    test "deletes chosen header", %{conn: conn, header: header} do
      conn = delete conn, header_path(conn, :delete, header)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, header_path(conn, :show, header)
      end
    end
  end

  defp create_header(_) do
    header = fixture(:header)
    {:ok, header: header}
  end
end
