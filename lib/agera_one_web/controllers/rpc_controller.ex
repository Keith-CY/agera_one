defmodule AgeraOneWeb.RpcController do
  use AgeraOneWeb, :controller
  alias AgeraOne.Chain
  alias AgeraOne.Repo
  alias AgeraOne.Chain.{Message, Block, Transaction, Metadata}
  alias AgeraOneWeb.{BlockView, TransactionView, MetadataView, ABIView, BalanceView}

  action_fallback(AgeraOneWeb.FallbackController)

  @doc """
    Get Peer count

    ### Params

    - {"method" => "peerCount"}

    ### Return

    - { "result": "0x3" }

  """
  def index(conn, %{"method" => "peerCount"}) do
    case Chain.get_peer_count() do
      {:ok, peer_count} ->
        conn
        |> render(MetadataView, "peer_count.json", peer_count: peer_count)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
    Get Metadata

    ### Params

    - {"method" => "getMetaData", "params" => [height]}

    ### Return

    - {
        "result": {
          "website": "https://www.example.com",
          "validators": [
            "0x208fddffb7615c7f31d06ea526a95af4ac24f996",
            "0xe1fcea5af28cf16fedc02083bd9c515e1d986881",
            "0xb0020393ae447ef6c58bf72989fc1c9fb393d256",
            "0x92aa443cb15db9990f60c14902eb590d3ba790ce"
          ],
          "operator": "test-operator",
          "number": "0x22235",
          "genesisTimestamp": "2018-06-14T07:13:47.261000Z",
          "chainName": "test-chain",
          "chainId": 1
        }
      }
  """
  def index(conn, %{"method" => "getMetaData", "params" => [number]}) do
    case Chain.get_metadata(number) do
      {:ok, %Metadata{} = metadata} ->
        conn |> render(MetadataView, "metadata.json", metadata: metadata)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
    Get ABI
  """
  def index(conn, %{"method" => "getAbi", "params" => [address, number]}) do
    case Chain.get_abi(address, number) do
      {:ok, abi} -> conn |> render(ABIView, "abi.json", abi: abi)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    Get Balance

    ### Params

    - { "method" => "getBalance", "params" => [addr, height] }

    ### Return

    - { "result": balance }
  """
  def index(conn, %{"method" => "getBalance", "params" => [address, number]}) do
    case Chain.get_balance(address, number) do
      {:ok, balance} -> conn |> render(BalanceView, "balance.json", balance: balance)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    Get Transaction Count of specified Account

    ### Params

    - { "method": "getTransactionCount", "params":["0x627306090abaB3A6e1400e9345bC60c78a8BEf57", "latest"] }

    ### Return

    - { "result": count }
  """
  def index(conn, %{"method" => "getTransactionCount", "params" => [addr, number]}) do
    case Chain.get_transaction_count(addr, number) do
      {:ok, count} -> conn |> render(TransactionView, "count.json", count: count)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
    Get Latest Block Number

    ### Params

    - { "method" => "blockNumber" }

    ### Return

    - { "result": number }
  """
  def index(conn, %{"method" => "blockNumber"}) do
    {:ok, number} = Chain.get_latest_block_number()

    conn
    |> render(BlockView, "block_number.json", number: number)
  end

  @doc """
    Get Transaction By Hash

    ### Params

    - { "method" => "getTransaction", "params" => [hash]}

    ### Return

    - { "result":
        {
          "value":null,
          "to":null,
          "timestamp":1529379404666,
          "hash":"0x760f07bc5482f3a084f5031da0d2794ddd0c4913dc9617005966ff9ed3425f10",
          "gasUsed":"0x0",
          "from":"0xd5ec01b4f7d8206bf01002d820ff54a0b8d9399d",
          "content":"0x0a1e186420bec3082a14627306090abab3a6e1400e9345bc60c78a8bef57380112410c68ec726f98a65ea766ad0700da48a596031ed52c286e0b8b7ca662308b61cb1ff9443dc9152e0071e24970fff7dec20431fa0a6663f43bdbf519f0ee4ae82501",
          "blockNumber":"0x22169"
        }
      }
  """
  def index(conn, %{"method" => "getTransaction", "params" => [hash]}) do
    case Chain.get_transaction(%{hash: hash}) do
      {:ok, %Transaction{} = transaction} ->
        conn
        |> render(TransactionView, "transaction-rpc.json", transaction: transaction)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false

  def index(conn, %{"method" => "getTransactionReceipt", "params" => [hash]}) do
    case Chain.get_transaction(%{hash: hash}) do
      {:ok, %Transaction{} = transaction} ->
        conn
        |> render(TransactionView, "transaction-receipt.json", transaction: transaction)

      {:error, reason} ->
        {:error, reason}
    end
  end

  # @doc false
  # def index(conn, %{"method" => "getTransactionReceipt", "params" => [hash]}) do
  #   case Chain.get_transaction(%{hash: hash}) do
  #     {:ok, %Transaction{} = transaction} ->
  #       conn
  #       |> render(TransactionView, "transaction.json", transaction: transaction)

  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end

  @doc """
    Get Block By Number of "latest", "earliest", hex, integer

    ### Params

    - { "method": "getBlockByNumber",
        "params": [
          number,
          false
        ],
      }

    ### Return

    - {
        "result": {
          "version": 0,
          "transactionsCount": 0,
          "header": {
            "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
            "timestamp": 1529384771621,
            "stateRoot": "0xd04c862bea8349cd2f8de4a4529cc259447f3a7bae4879710e3ada192b4f567d",
            "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
            "proof": {
              "Tendermint": {
                "proposal": "0x60e01a9ca9957bf3384f97c4567c29b47dab8d36"
              }
            },
            "prevHash": "0xffd7730acc9ce1540654fc9668eb93cbc4996141449a91ae1f9182684ac76d9e",
            "number": "0x2F",
            "gasUsed": "0x0"
          },
          "hash": "0x02f2a786644df9320202f15dfff19a4fbfb9031f9e2a971438b2700570a0f394",
          "body": {
            "transactions": []
          }
        }
      }
  """
  def index(conn, %{"method" => "getBlockByNumber", "params" => [number, detailed]}) do
    case get_block(%{number: number}) do
      {:ok, block} ->
        render_block(conn, block, detailed)

      error ->
        error
    end
  end

  @doc """
    Get Block By Hash

    ### Params

    - { "method": "getBlockByHash",
        "params": [
          hash,
          false
        ],
      }

    ### Return

    - {
        "result": {
          "version": 0,
          "transactionsCount": 0,
          "header": {
            "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
            "timestamp": 1529384771621,
            "stateRoot": "0xd04c862bea8349cd2f8de4a4529cc259447f3a7bae4879710e3ada192b4f567d",
            "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
            "proof": {
              "Tendermint": {
                "proposal": "0x60e01a9ca9957bf3384f97c4567c29b47dab8d36"
              }
            },
            "prevHash": "0xffd7730acc9ce1540654fc9668eb93cbc4996141449a91ae1f9182684ac76d9e",
            "number": "0x2F",
            "gasUsed": "0x0"
          },
          "hash": "0x02f2a786644df9320202f15dfff19a4fbfb9031f9e2a971438b2700570a0f394",
          "body": {
            "transactions": []
          }
        }
      }
  """
  def index(conn, %{"method" => "getBlockByHash", "params" => [hash, detailed]}) do
    case get_block(%{hash: hash}) do
      {:ok, block} ->
        render_block(conn, block, detailed)

      error ->
        error
    end
  end

  @doc false
  def get_block(params) do
    case Chain.get_block(params) do
      {:ok, %Block{} = block} ->
        {:ok, block |> Repo.preload([:transactions])}

      error ->
        error
    end
  end

  @doc false
  defp render_block(conn, block, detailed \\ false) do
    case detailed do
      false ->
        conn |> render(BlockView, "block-transaction-hash.json", block: block)

      _ ->
        conn |> render(BlockView, "block-transaction-hash-content.json", block: block)
    end
  end

  @doc false
  def index(conn, _) do
    # rende
  end
end
