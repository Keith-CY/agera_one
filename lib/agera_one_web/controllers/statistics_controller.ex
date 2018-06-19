defmodule AgeraOneWeb.StatisticsController do
  use AgeraOneWeb, :controller

  alias AgeraOne.Chain

  action_fallback(AgeraOneWeb.FallbackController)

  @doc false
  def index(conn, %{"type" => "proposals"}) do
    case Chain.get_proposal_count() do
      {:ok, proposals} -> conn |> render("proposals.json", proposals: proposals)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get Proposals Distribution

  ## Params
      {
        "type" => "proposals" | "brief"
      }

  ## Return

    - "type" => "proposals"

    ```
      {
        "result": [
          {
            "validator": "0x208fddffb7615c7f31d06ea526a95af4ac24f996",
            "count": 34956
          },
          {
            "validator": "0xe1fcea5af28cf16fedc02083bd9c515e1d986881",
            "count": 34955
          },
          {
            "validator": "0xb0020393ae447ef6c58bf72989fc1c9fb393d256",
            "count": 34957
          },
          {
            "validator": "0x92aa443cb15db9990f60c14902eb590d3ba790ce",
            "count": 34961
          }
        ]
      }
    ```

    - "type" => "brief"

    ```
      {
        "result": {
          "tps": 0,
          "tpb": 0,
          "ipb": 0.0021240229137017355
        }
      }
    ```
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
