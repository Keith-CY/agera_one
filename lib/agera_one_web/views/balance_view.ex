defmodule AgeraOneWeb.BalanceView do
  use AgeraOneWeb, :view
  alias AgeraOneWeb.BalanceView

  def render("index.json", %{balances: balances}) do
    %{data: render_many(balances, BalanceView, "balance.json")}
  end

  def render("show.json", %{balance: balance}) do
    %{data: render_one(balance, BalanceView, "balance.json")}
  end

  def render("balance.json", %{balance: balance}) do
    IO.inspect(balance)
    %{result: balance.value}
  end
end
