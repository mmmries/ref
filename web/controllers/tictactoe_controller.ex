defmodule Ref.TictactoeController do
  use Ref.Web, :controller

  def play(conn, %{"id" => id}=params) do
    render conn, "play.html", id: id, just_watching: false, ai: Dict.get(params, "ai")
  end

  def tutorial(conn, %{}) do
    render conn, "tutorial.html"
  end

  def watch(conn, %{"id" => id}=params) do
    render conn, "play.html", id: id, just_watching: true, ai: Dict.get(params, "ai")
  end
end
