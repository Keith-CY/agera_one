defmodule AgeraOneWeb.Router do
  use AgeraOneWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", AgeraOneWeb do
    pipe_through(:api)
    resources("/blocks", BlockController, except: [:new, :edit])
    resources("/transactions", TransactionController, except: [:new, :edit])
  end

  scope "/", AgeraOneWeb do
    pipe_through(:api)
    post("/", RpcController, :index)
  end
end
