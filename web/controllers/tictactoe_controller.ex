defmodule Ref.TictactoeController do
  use Ref.Web, :controller

  def play(conn, %{"id" => id}) do
    render conn, "play.html", id: id, just_watching: false
  end

  def watch(conn, %{"id" => id}) do
    render conn, "play.html", id: id, just_watching: true
  end
end
