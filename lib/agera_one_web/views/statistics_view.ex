defmodule AgeraOneWeb.StatisticsView do
  use AgeraOneWeb, :view

  def render("proposals.json", %{proposals: proposals}) do
    IO.inspect(proposals)

    %{
      result: proposals
    }
  end

  def render("brief.json", params) do
    %{
      result: %{
        tps: params |> Map.get(:tps),
        tpb: params |> Map.get(:tpb),
        ipb: params |> Map.get(:ipb)
        # proposals: params |> Map.get(:proposals)
      }
    }
  end
end
