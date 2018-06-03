defmodule AgeraOne.Chain.Message do
  use Protobuf, from: Path.expand("./transaction.proto", __DIR__)
  alias AgeraOne.Chain.Message

  def parse_unverified_transaction(tx_content) do
    case decode_unverified_transaction(tx_content) do
      {:ok, %{signature: signature, transaction: transaction}} ->
        {:ok, signature, transaction}

      err ->
        err
    end
  end

  def decode_unverified_transaction(tx_content) do
    tx_bytes = tx_content |> hex_to_bytes

    try do
      {:ok, Message.UnverifiedTransaction.decode(tx_bytes)}
    rescue
      ErlangError ->
        {:error, "Cannot decode transaction content"}
    end
  end

  def hex_to_buffer(hex) do
    for <<x::binary-2 <- String.slice(hex, 2..-1)>> do
      case Integer.parse(x, 16) do
        {int, ""} -> int
        err -> err
      end
    end
  end

  def hex_to_bytes(tx_content) do
    tx_content
    |> hex_to_buffer
    |> :binary.list_to_bin()
  end

  def bytes_to_hex(bytes) do
    bytes |> Base.encode16()
  end

  def get_from(content) do
    {:ok, sig, tx} = parse_unverified_transaction(content)

    tx_hash =
      tx |> Message.Transaction.encode() |> String.slice(4..-3) |> ExthCrypto.Hash.Keccak.kec()

    r = sig |> String.slice(0..31)
    s = sig |> String.slice(32..63)
    <<v>> = sig |> String.slice(-1..-1)

    IO.inspect("r is #{r}, and s is #{s}")

    case ExthCrypto.Signature.recover(tx_hash, sig, v) do
      {:ok, pubkey} ->
        {:ok,
         "0x" <>
           (pubkey
            |> String.slice(1..-1)
            |> ExthCrypto.Hash.Keccak.kec()
            |> Base.encode16(case: :lower)
            |> String.slice(-40..-1))}
    end
  end
end
