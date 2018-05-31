defmodule AgeraOneWeb.ABIView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.ABIView

  def render("index.json", %{abis: abis}) do
    %{data: render_many(abis, ABIView, "abi.json")}
  end

  def render("show.json", %{abi: abi}) do
    %{data: render_one(abi, ABIView, "abi.json")}
  end

  def render("abi.json", %{abi: abi}) do
    %{result: abi.content}
  end
end
