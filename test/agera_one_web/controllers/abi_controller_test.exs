defmodule AgeraOneWeb.ABIControllerTest do
  use AgeraOneWeb.ConnCase

  alias AgeraOne.Chain
  alias AgeraOne.Chain.ABI

  @create_attrs %{addr: "some addr", content: "some content", number: "some number"}
  @update_attrs %{addr: "some updated addr", content: "some updated content", number: "some updated number"}
  @invalid_attrs %{addr: nil, content: nil, number: nil}

  def fixture(:abi) do
    {:ok, abi} = Chain.create_abi(@create_attrs)
    abi
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all abis", %{conn: conn} do
      conn = get conn, abi_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create abi" do
    test "renders abi when data is valid", %{conn: conn} do
      conn = post conn, abi_path(conn, :create), abi: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, abi_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "addr" => "some addr",
        "content" => "some content",
        "number" => "some number"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, abi_path(conn, :create), abi: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update abi" do
    setup [:create_abi]

    test "renders abi when data is valid", %{conn: conn, abi: %ABI{id: id} = abi} do
      conn = put conn, abi_path(conn, :update, abi), abi: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, abi_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "addr" => "some updated addr",
        "content" => "some updated content",
        "number" => "some updated number"}
    end

    test "renders errors when data is invalid", %{conn: conn, abi: abi} do
      conn = put conn, abi_path(conn, :update, abi), abi: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete abi" do
    setup [:create_abi]

    test "deletes chosen abi", %{conn: conn, abi: abi} do
      conn = delete conn, abi_path(conn, :delete, abi)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, abi_path(conn, :show, abi)
      end
    end
  end

  defp create_abi(_) do
    abi = fixture(:abi)
    {:ok, abi: abi}
  end
end
