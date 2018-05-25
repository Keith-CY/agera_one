defmodule AgeraOne.ChainTest do
  use AgeraOne.DataCase

  alias AgeraOne.Chain

  describe "blocks" do
    alias AgeraOne.Chain.Block

    @valid_attrs %{hash: "some hash", version: 42}
    @update_attrs %{hash: "some updated hash", version: 43}
    @invalid_attrs %{hash: nil, version: nil}

    def block_fixture(attrs \\ %{}) do
      {:ok, block} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chain.create_block()

      block
    end

    test "list_blocks/0 returns all blocks" do
      block = block_fixture()
      assert Chain.list_blocks() == [block]
    end

    test "get_block!/1 returns the block with given id" do
      block = block_fixture()
      assert Chain.get_block!(block.id) == block
    end

    test "create_block/1 with valid data creates a block" do
      assert {:ok, %Block{} = block} = Chain.create_block(@valid_attrs)
      assert block.hash == "some hash"
      assert block.version == 42
    end

    test "create_block/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chain.create_block(@invalid_attrs)
    end

    test "update_block/2 with valid data updates the block" do
      block = block_fixture()
      assert {:ok, block} = Chain.update_block(block, @update_attrs)
      assert %Block{} = block
      assert block.hash == "some updated hash"
      assert block.version == 43
    end

    test "update_block/2 with invalid data returns error changeset" do
      block = block_fixture()
      assert {:error, %Ecto.Changeset{}} = Chain.update_block(block, @invalid_attrs)
      assert block == Chain.get_block!(block.id)
    end

    test "delete_block/1 deletes the block" do
      block = block_fixture()
      assert {:ok, %Block{}} = Chain.delete_block(block)
      assert_raise Ecto.NoResultsError, fn -> Chain.get_block!(block.id) end
    end

    test "change_block/1 returns a block changeset" do
      block = block_fixture()
      assert %Ecto.Changeset{} = Chain.change_block(block)
    end
  end

  describe "headers" do
    alias AgeraOne.Chain.Header

    @valid_attrs %{gas_used: "some gas_used", number: "some number", prev_hash: "some prev_hash", proporser: "some proporser", receipts_root: "some receipts_root", state_root: "some state_root", timestamp: ~D[2010-04-17], transactions_root: "some transactions_root"}
    @update_attrs %{gas_used: "some updated gas_used", number: "some updated number", prev_hash: "some updated prev_hash", proporser: "some updated proporser", receipts_root: "some updated receipts_root", state_root: "some updated state_root", timestamp: ~D[2011-05-18], transactions_root: "some updated transactions_root"}
    @invalid_attrs %{gas_used: nil, number: nil, prev_hash: nil, proporser: nil, receipts_root: nil, state_root: nil, timestamp: nil, transactions_root: nil}

    def header_fixture(attrs \\ %{}) do
      {:ok, header} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chain.create_header()

      header
    end

    test "list_headers/0 returns all headers" do
      header = header_fixture()
      assert Chain.list_headers() == [header]
    end

    test "get_header!/1 returns the header with given id" do
      header = header_fixture()
      assert Chain.get_header!(header.id) == header
    end

    test "create_header/1 with valid data creates a header" do
      assert {:ok, %Header{} = header} = Chain.create_header(@valid_attrs)
      assert header.gas_used == "some gas_used"
      assert header.number == "some number"
      assert header.prev_hash == "some prev_hash"
      assert header.proporser == "some proporser"
      assert header.receipts_root == "some receipts_root"
      assert header.state_root == "some state_root"
      assert header.timestamp == ~D[2010-04-17]
      assert header.transactions_root == "some transactions_root"
    end

    test "create_header/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chain.create_header(@invalid_attrs)
    end

    test "update_header/2 with valid data updates the header" do
      header = header_fixture()
      assert {:ok, header} = Chain.update_header(header, @update_attrs)
      assert %Header{} = header
      assert header.gas_used == "some updated gas_used"
      assert header.number == "some updated number"
      assert header.prev_hash == "some updated prev_hash"
      assert header.proporser == "some updated proporser"
      assert header.receipts_root == "some updated receipts_root"
      assert header.state_root == "some updated state_root"
      assert header.timestamp == ~D[2011-05-18]
      assert header.transactions_root == "some updated transactions_root"
    end

    test "update_header/2 with invalid data returns error changeset" do
      header = header_fixture()
      assert {:error, %Ecto.Changeset{}} = Chain.update_header(header, @invalid_attrs)
      assert header == Chain.get_header!(header.id)
    end

    test "delete_header/1 deletes the header" do
      header = header_fixture()
      assert {:ok, %Header{}} = Chain.delete_header(header)
      assert_raise Ecto.NoResultsError, fn -> Chain.get_header!(header.id) end
    end

    test "change_header/1 returns a header changeset" do
      header = header_fixture()
      assert %Ecto.Changeset{} = Chain.change_header(header)
    end
  end

  describe "transactions" do
    alias AgeraOne.Chain.Transaction

    @valid_attrs %{content: "some content", hash: "some hash"}
    @update_attrs %{content: "some updated content", hash: "some updated hash"}
    @invalid_attrs %{content: nil, hash: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chain.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Chain.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Chain.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Chain.create_transaction(@valid_attrs)
      assert transaction.content == "some content"
      assert transaction.hash == "some hash"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chain.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, transaction} = Chain.update_transaction(transaction, @update_attrs)
      assert %Transaction{} = transaction
      assert transaction.content == "some updated content"
      assert transaction.hash == "some updated hash"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Chain.update_transaction(transaction, @invalid_attrs)
      assert transaction == Chain.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Chain.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Chain.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Chain.change_transaction(transaction)
    end
  end
end
