defmodule AgeraOne.Chain do
  @moduledoc """
  The Chain context.
  """

  import Ecto.Query, warn: false
  alias AgeraOne.Repo

  alias AgeraOne.Chain.{Block, Header, Transaction, Message, Metadata}

  @chain_url "http://47.75.129.215:1337/"

  @doc false
  def sync_peer_count() do
    request_chain("net_peerCount")
  end

  def get_peer_count() do
    case Repo.one(from(m in Metadata, order_by: [desc: m.timestamp], limit: 1)) do
      %{peer_count: peer_count} -> {:ok, peer_count}
      nil -> {:error, :not_found}
    end
  end

  @doc false
  def get_metadata(number) do
    case Repo.get_by(Metadata, number: number) do
      %Metadata{} = metadata -> {:ok, metadata}
      nil -> {:error, :not_found}
    end
  end

  @doc false

  def sync_metadata(number) do
    with {:ok, metadata} <- request_chain("cita_getMetaData", [number]),
         {:ok, peer_count} <- sync_peer_count() do
      metadata |> Map.put("number", number) |> Map.put("peerCount", peer_count) |> create_metadata
    else
      error -> {:error, error}
    end
  end

  def create_metadata(metadata_params \\ %{}) do
    %Metadata{}
    |> Metadata.changeset(metadata_params)
    |> Repo.insert()
  end

  @doc false
  def list_blocks do
    Repo.all(Block) |> Repo.preload([:header, :transactions])
  end

  @doc false
  def list_page_blocks(offset \\ 0, limit \\ 10) do
    Repo.all(from(b in Block, offset: ^offset, limit: ^limit)) |> Repo.preload([:header])
  end

  @doc false
  def get_block(%{number: number}) do
    case get_header(%{number: number}) do
      %{block: block} ->
        {:ok, block |> Repo.preload([:header])}

      _ ->
        case request_chain("cita_getBlockByNumber", [number, false]) do
          {:ok, data} ->
            cache_block(data)

          error ->
            error
        end
    end
  end

  @doc false
  def get_block(%{hash: hash}) do
    case Repo.get_by(Block, hash: hash) do
      %Block{} = block ->
        {:ok, block |> Repo.preload([:header])}

      _ ->
        case request_chain("cita_getBlockByHash", [hash, false]) do
          {:ok, data} ->
            cache_block(data)

          error ->
            error
        end
    end
  end

  @doc false
  def get_block(id), do: Repo.get(Block, id) |> Repo.preload([:header])

  @doc false
  def get_latest_block_header() do
    Repo.one(from(h in Header, order_by: [desc: h.timestamp], limit: 1))
  end

  @doc false
  def create_block(block_params \\ %{}, header_params, tx_hashes \\ []) do
    %Block{}
    |> Block.changeset(block_params)
    |> Ecto.Changeset.put_assoc(
      :transactions,
      Enum.map(tx_hashes, fn tx_hash ->
        case get_transaction(%{hash: tx_hash}) do
          {:ok, tx} -> tx |> change_transaction
          {:error, error} -> IO.inspect(error)
        end
      end)
    )
    |> Ecto.Changeset.put_assoc(:header, header_params)
    |> Repo.insert()
  end

  @doc false
  def update_block(%Block{} = block, attrs) do
    block
    |> Block.changeset(attrs)
    |> Repo.update()
  end

  @doc false
  def delete_block(%Block{} = block) do
    Repo.delete(block)
  end

  @doc false
  def change_block(%Block{} = block) do
    Block.changeset(block, %{})
  end

  alias AgeraOne.Chain.Header

  @doc false
  def list_headers do
    Repo.all(Header)
  end

  @doc false
  def get_header(%{number: number}),
    do: Repo.get_by(Header, number: number) |> Repo.preload(:block)

  @doc false
  def get_header(id), do: Repo.get(Header, id)

  @doc false
  def create_header(attrs \\ %{}) do
    %Header{}
    |> Header.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def update_header(%Header{} = header, attrs) do
    header
    |> Header.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  cache block into db
  """
  def cache_block(
        %{
          "body" => body,
          "header" => %{
            "gasUsed" => gas_used,
            "number" => number,
            "prevHash" => prev_hash,
            "proposer" => proposer,
            "receiptsRoot" => receipts_root,
            "timestamp" => timestamp,
            "transactionsRoot" => transactions_root,
            "stateRoot" => state_root
          }
        } = block
      ) do
    header = %Header{
      gas_used: gas_used,
      number: number,
      prev_hash: prev_hash,
      proposer: proposer,
      receipts_root: receipts_root,
      timestamp: get_time(timestamp),
      transactions_root: transactions_root,
      state_root: state_root
    }

    tx_hashes = Map.get(body, "transactions") || []
    block = Map.put(block, "transactions_count", Kernel.length(tx_hashes))

    result = create_block(block, header, tx_hashes)
    result
  end

  def sync_block() do
    current =
      case get_latest_block_header() do
        %Header{number: number} ->
          hex_to_int(number)

        _ ->
          0
      end

    number = (current + 1) |> int_to_hex
    sync_metadata(number)
    get_block(%{number: number})
  end

  @doc false
  def change_header(%Header{} = header) do
    Header.changeset(header, %{})
  end

  @doc """
    Request chain
  """
  def request_chain(method, params \\ []) do
    rpc_params = json_rpc_params(method, params)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(@chain_url, rpc_params),
         {:ok, decoded} <- Poison.decode(body),
         %{"result" => result} <- decoded do
      {:ok, result}
    else
      err -> err
    end
  end

  @doc """
  JSON RPC Params Formatter

  ## Example
    iex> json_rpc_params(%{method: "M", params: "P"})
    %{id: 1, jsonrpc: "2.0", method: "M", params: ["P"]}
  """
  def json_rpc_params(method, params \\ []) do
    Poison.encode!(%{
      jsonrpc: "2.0",
      method: method,
      params: params,
      id: 1
    })
  end

  alias AgeraOne.Chain.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  """
  def list_page_transactions(offset \\ 0, limit \\ 10) do
    Repo.all(from(t in Transaction, limit: ^limit, offset: ^offset)) |> Repo.preload([:block])
  end

  @doc false
  def get_transaction(%{hash: hash}) do
    case Repo.get_by(Transaction, hash: hash) do
      nil ->
        request_transaction(hash)

      transaction ->
        {:ok, transaction}
    end
  end

  @doc false
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Request Transaction and Receipt by hash
  """
  def request_transaction(hash) do
    with(
      {:ok, %{"content" => content, "hash" => hash}} <-
        request_chain("cita_getTransaction", [hash]),
      {:ok,
       %{
         "blockHash" => block_hash,
         "blockNumber" => block_number,
         "contractAddress" => contract_address,
         "gasUsed" => gas_used,
         "transactionIndex" => index
       }} <- request_chain("eth_getTransactionReceipt", [hash])
    ) do
      {:ok,
       %Transaction{
         content: content,
         hash: hash,
         block_hash: block_hash,
         block_number: block_number,
         contract_address: contract_address,
         gas_used: gas_used,
         index: index
       }}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "request tx or receipt failed"}
    end
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{source: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction) do
    Transaction.changeset(transaction, %{})
  end

  def get_time(timestamp) do
    case DateTime.from_unix(timestamp, :millisecond) do
      {:ok, time} ->
        time

      _ ->
        timestamp
    end
  end

  def int_to_hex(int) when is_integer(int) do
    "0x" <> Integer.to_string(int, 16)
  end

  def int_to_hex(int) do
    int
  end

  def hex_to_int(hex) when is_binary(hex) do
    {int, ""} =
      hex
      |> String.slice(2..-1)
      |> Integer.parse(16)

    int
  end

  def hex_to_int(hex) do
    hex
  end

  alias AgeraOne.Chain.ABI

  @doc """
  Returns the list of abis.

  ## Examples

      iex> list_abis()
      [%ABI{}, ...]

  """
  def list_abis do
    Repo.all(ABI)
  end

  @doc """
  Gets a single abi.

  Raises `Ecto.NoResultsError` if the Abi does not exist.

  ## Examples

      iex> get_abi!(123)
      %ABI{}

      iex> get_abi!(456)
      ** (Ecto.NoResultsError)

  """
  def get_abi!(id), do: Repo.get!(ABI, id)

  @doc """
  Creates a abi.

  ## Examples

      iex> create_abi(%{field: value})
      {:ok, %ABI{}}

      iex> create_abi(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_abi(attrs \\ %{}) do
    %ABI{}
    |> ABI.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a abi.

  ## Examples

      iex> update_abi(abi, %{field: new_value})
      {:ok, %ABI{}}

      iex> update_abi(abi, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_abi(%ABI{} = abi, attrs) do
    abi
    |> ABI.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ABI.

  ## Examples

      iex> delete_abi(abi)
      {:ok, %ABI{}}

      iex> delete_abi(abi)
      {:error, %Ecto.Changeset{}}

  """
  def delete_abi(%ABI{} = abi) do
    Repo.delete(abi)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking abi changes.

  ## Examples

      iex> change_abi(abi)
      %Ecto.Changeset{source: %ABI{}}

  """
  def change_abi(%ABI{} = abi) do
    ABI.changeset(abi, %{})
  end
end
