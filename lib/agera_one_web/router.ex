defmodule AgeraOneWeb.Router do
  use AgeraOneWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", AgeraOneWeb do
    pipe_through(:api)
    resources("/blocks", BlockController, except: [:new, :edit])
    resources("/transactions", TransactionController, except: [:new, :edit])
    resources("/abis", ABIController, except: [:new, :edit])
    resources("/balances", BalanceController, except: [:new, :edit])
    get("/statistics", StatisticsController, :index)
  end

  scope "/", AgeraOneWeb do
    pipe_through(:api)
    post("/", RpcController, :index)
  end
end
