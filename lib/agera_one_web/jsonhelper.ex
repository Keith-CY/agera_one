defmodule AgeraOneWeb.JSONHelpers do
  alias AgeraOne.Chain

  def hex_to_int(hex) do
    hex |> Chain.hex_to_int()
  end

  def int_to_hex(int) do
    int |> Chain.int_to_hex()
  end
end
