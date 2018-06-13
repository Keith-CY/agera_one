defmodule AgeraOne.Chain do
  @moduledoc """
  The Chain context.
  """

  import Ecto.Query, warn: false
  alias AgeraOne.Repo

  alias AgeraOne.Chain.{Block, Transaction, Message, Metadata, ABI, Balance}

  @chain_url "http://47.75.129.215:1337/"

  @doc false
  def sync_10() do
    for _ <- 1..10 do
      sync_block()
    end
  end

  @doc false
  def sync_peer_count() do
    request_chain("net_peerCount")
  end

  def get_peer_count() do
    case Repo.one(from(m in Metadata, order_by: [desc: m.number], select: m.peer_count, limit: 1)) do
      nil -> {:error, :not_found}
      peer_count -> {:ok, peer_count}
    end
  end

  @doc false
  def get_metadata(number \\ "latest") do
    number = number |> number_formatter() |> hex_to_int()

    case Repo.get_by(Metadata, number: number) do
      %Metadata{} = metadata -> {:ok, metadata}
      nil -> {:error, :not_found}
    end
  end

  @doc false

  def sync_metadata(number \\ "latest") do
    number = number |> number_formatter()

    case get_metadata(number) do
      {:ok, metadata} ->
        {:ok, metadata}

      _ ->
        with {:ok, metadata} <- request_chain("cita_getMetaData", [number]),
             {:ok, peer_count} <- sync_peer_count() do
          metadata
          |> Map.put("number", number)
          |> Map.put("peerCount", peer_count)
          |> create_metadata
        else
          error -> {:error, error}
        end
    end
  end

  def get_abi(addr, spec_number \\ "latest") do
    spec_number = spec_number |> number_formatter()
    abi = Repo.one(ABI, addr: addr)

    if !is_nil(abi) and hex_to_int(abi.number) <= hex_to_int(spec_number) do
      {:ok, abi}
    else
      IO.puts("Requesting ABI at addr: #{addr}, number: #{spec_number}")

      case request_chain("eth_getAbi", [addr, spec_number]) do
        {:ok, "0x"} ->
          {:ok, %{content: "0x", addr: addr, number: spec_number |> int_to_hex()}}

        {:ok, remote_abi} ->
          cond do
            is_nil(abi) ->
              %{content: remote_abi, number: spec_number, addr: addr} |> create_abi

            true ->
              update_abi(abi, %{number: spec_number, content: remote_abi})
          end

        error ->
          {:error, error}
      end
    end
  end

  @doc false
  def get_balance(addr, spec_number \\ "latest") do
    spec_number = spec_number |> number_formatter()
    balance = Repo.one(Balance, addr: addr)

    if !is_nil(balance) and hex_to_int(balance.number) >= hex_to_int(spec_number) do
      {:ok, balance}
    else
      IO.puts("Requesting Balance at addr: #{addr}, number: #{spec_number}")

      case request_chain("eth_getBalance", [addr, spec_number]) do
        {:ok, "0x"} ->
          {:ok, %{value: "0x0", addr: addr, spec_number: spec_number |> int_to_hex()}}

        {:ok, remote_balance} ->
          cond do
            is_nil(balance) ->
              %{value: remote_balance, number: spec_number, addr: addr} |> create_balance

            true ->
              update_balance(balance, %{number: spec_number, value: remote_balance})
          end

        error ->
          {:error, error}
      end
    end
  end

  def create_metadata(metadata_params \\ %{}) do
    %Metadata{}
    |> Metadata.changeset(metadata_params)
    |> Repo.insert()
  end

  @doc false
  def list_blocks do
    Repo.all(Block) |> Repo.preload([:transactions])
  end

  def get_blocks(%{
        number_from: number_from,
        number_to: number_to,
        transaction_from: transaction_from,
        transaction_to: transaction_to,
        offset: offset,
        limit: limit
      }) do
    query = Block

    query =
      case number_from do
        nil -> query
        number_from -> query |> where([b], b.number >= ^number_from)
      end

    query =
      case number_to do
        nil -> query
        number_to -> query |> where([b], b.number <= ^number_to)
      end

    query =
      case transaction_from do
        nil -> query
        transaction_from -> query |> where([b], b.transactions_count >= ^transaction_from)
      end

    query =
      case transaction_to do
        nil -> query
        transaction_to -> query |> where([b], b.transactions_count <= ^transaction_to)
      end

    offset = offset || 0
    limit = limit || 10
    limited_query = query |> order_by(desc: :number) |> offset(^offset) |> limit(^limit)
    count_query = query |> select([t], count(t.id))

    case limited_query |> Repo.all() do
      nil -> {:error, :not_found}
      blocks -> {:ok, blocks, count_query |> Repo.one()}
    end
  end

  def get_blocks(%{
        numberFrom: numberFrom,
        numberTo: numberTo,
        transactionFrom: transactionFrom,
        transactionTo: transactionTo
      }) do
    case Repo.all(
           from(
             b in Block,
             where:
               b.number >= ^numberFrom and b.number <= ^numberTo and
                 b.transactions_count >= ^transactionFrom and
                 b.transactions_count <= ^transactionTo,
             order_by: [desc: :number]
           )
         ) do
      nil -> {:error, :not_found}
      blocks -> {:ok, blocks, blocks |> Kernal.length()}
    end
  end

  @doc false
  def get_blocks(offset \\ 0, limit \\ 10) do
    case Repo.all(from(b in Block, offset: ^offset, limit: ^limit, order_by: [desc: :number])) do
      nil -> {:error, :not_found}
      blocks -> {:ok, blocks, Block |> Repo.aggregate(:count, :hash)}
    end
  end

  @doc false
  def get_block(%{number: number}) do
    number = number |> hex_to_int()

    case Repo.get_by(Block, number: number) do
      nil ->
        case request_chain("cita_getBlockByNumber", [number |> int_to_hex(), false]) do
          {:ok, data} ->
            cache_block(data)

          error ->
            error
        end

      block ->
        {:ok, block}
    end
  end

  @doc false
  def get_block(%{hash: hash}) do
    case Repo.get_by(Block, hash: hash) do
      %Block{} = block ->
        {:ok, block}

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
  def get_block(id), do: Repo.get(Block, id)

  @doc false

  def get_latest_block_number() do
    case Repo.one(from(b in Block, order_by: [desc: b.number], limit: 1, select: b.number)) do
      nil -> {:ok, -1}
      number -> {:ok, number}
    end
  end

  @doc false
  def create_block(block_params \\ %{}, tx_hashes \\ []) do
    %Block{}
    |> Block.changeset(block_params)
    |> Ecto.Changeset.put_assoc(
      :transactions,
      Enum.map(tx_hashes, fn tx_hash ->
        case get_transaction(%{hash: tx_hash}) do
          {:ok, tx} -> tx |> change_transaction
          {:error, error} -> IO.inspect({:chain, error})
        end
      end)
    )
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
    tx_hashes = Map.get(body, "transactions") || []

    block = Map.put(block, "gas_used", gas_used)
    block = Map.put(block, "prev_hash", prev_hash)
    block = Map.put(block, "proposer", proposer)
    block = Map.put(block, "receipts_root", receipts_root)
    block = Map.put(block, "transactions_root", transactions_root)
    block = Map.put(block, "state_root", state_root)

    block = Map.put(block, "transactions_count", Kernel.length(tx_hashes))
    block = Map.put(block, "number", number |> hex_to_int())
    block = Map.put(block, "timestamp", get_time(timestamp))

    result = create_block(block, tx_hashes)
    result
  end

  def cache_block(block) do
    block
  end

  def sync_block() do
    {:ok, current} = get_latest_block_number()
    IO.puts(current)
    number = current + 1
    sync_metadata(number)
    get_block(%{number: number})
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
      cond do
        is_nil(result) -> {:error, :not_found}
        true -> {:ok, result}
      end
    else
      {:error, reason} -> {:error, reason}
      err -> err
    end
  end

  def get_transaction_count(addr, number \\ "latest") do
    number = number |> number_formatter()
    request_chain("eth_getTransactionCount", [addr, number])
  end

  @doc false
  def json_rpc_params(method, params \\ []) do
    Poison.encode!(%{
      jsonrpc: "2.0",
      method: method,
      params: params,
      id: 1
    })
  end

  def number_formatter(number) do
    cond do
      number == "latest" ->
        case get_latest_block_number() do
          {:ok, -1} -> "0x0"
          {:ok, current} -> current |> int_to_hex()
        end

      number == "earliest" ->
        "0x0"

      true ->
        number |> int_to_hex()
    end
  end

  alias AgeraOne.Chain.Transaction

  def get_transactions(%{
        account: account,
        from: from,
        to: to,
        value_from: value_from,
        value_to: value_to,
        offset: offset,
        limit: limit
      }) do
    query = Transaction

    query =
      case from do
        nil -> query
        from -> query |> where([t], t.from == ^from)
      end

    query =
      case to do
        nil -> query
        to -> query |> where([t], t.to == ^to)
      end

    query =
      case account do
        nil -> query
        account -> query |> where([t], t.from == ^account or t.to == ^account)
      end

    query =
      case value_from do
        nil -> query
        value_from -> query |> where([t], t.value >= ^value_from)
      end

    query =
      case value_to do
        nil -> query
        value_from -> query |> where([t], t.value <= ^value_to)
      end

    offset = offset || 0
    limit = limit || 10

    limited_query =
      query |> order_by(desc: :block_number, asc: :index) |> offset(^offset) |> limit(^limit)

    count_query = query |> select([t], count(t.id))

    case limited_query |> Repo.all() do
      nil -> {:error, :not_found}
      transactions -> {:ok, transactions |> Repo.preload([:block]), count_query |> Repo.one()}
    end
  end

  @doc false

  def get_transaction(%{hash: hash}) do
    case Repo.get_by(Transaction, hash: hash) do
      nil ->
        request_transaction(hash)

      transaction ->
        {:ok, transaction |> Repo.preload([:block])}
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
  """
  def create_abi(attrs \\ %{}) do
    %ABI{}
    |> ABI.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a abi.
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

  @doc """
  """
  def create_balance(attrs \\ %{}) do
    %Balance{}
    |> Balance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a abi.
  """
  def update_balance(%Balance{} = balance, attrs) do
    balance
    |> Balance.changeset(attrs)
    |> Repo.update()
  end
end
