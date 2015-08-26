defmodule Ref.PageController do
  use Ref.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def play(conn, %{"id" => id}) do
    render conn, "play.html", id: id
  end
end
