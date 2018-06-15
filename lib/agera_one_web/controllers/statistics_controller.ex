defmodule AgeraOneWeb.StatisticsController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain

  action_fallback(AgeraOneWeb.FallbackController)

  def index(conn, %{"type" => "proposals"}) do
    case Chain.get_proposal_count() do
      {:ok, proposals} -> conn |> render("proposals.json", proposals: proposals)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Return TPS, Avg Txs, Avg Interval, Proposals of latest 100 blocks
  """
  def index(conn, %{"type" => "brief"} = params) do
    case Chain.get_blocks(%{limit: params["limit"] || 100}) do
      {:ok, blocks, count} ->
        first_time = blocks |> List.first() |> Map.get(:timestamp) |> DateTime.to_unix(:second)
        last_time = blocks |> List.last() |> Map.get(:timestamp) |> DateTime.to_unix(:second)
        duration = first_time - last_time

        transactions_count = blocks |> sum_transactions()
        tps = transactions_count / duration
        tpb = transactions_count / count
        # interval per block
        ipb = duration / (count - 1)

        # case Chain.get_proposal_count() do
        #   {:ok, proposals} ->
        #     conn
        #     |> render("brief.json", tps: tps, tpb: tpb, dpb: dpb, proposals: proposals)

        #   {:error} ->
        conn
        |> render("brief.json", tps: tps, tpb: tpb, ipb: ipb)

      # end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp sum_transactions(blocks) do
    blocks |> Enum.map(fn b -> b.transactions_count end) |> :lists.sum()
  end
end
