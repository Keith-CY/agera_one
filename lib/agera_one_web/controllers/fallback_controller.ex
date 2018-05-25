defmodule AgeraOneWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use AgeraOneWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(AgeraOneWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(AgeraOneWeb.ErrorView, :"404")
  end

  def call(conn, {:error, msg}) do
    conn
    |> render(AgeraOneWeb.ErrorView, "msg.json", msg: msg)
  end

  # def call(conn, %{:error, msg}) do
  #   conn
  #   |> render(AgeraOneWeb.ErrorView, "msg.json", msg: msg)
  # end
end
