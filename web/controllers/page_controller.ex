defmodule Ref.PageController do
  use Ref.Web, :controller
  alias Ref.TicTacToe

  def index(conn, _params) do
    render conn, "index.html", ongoing_games: ongoing_game_ids
  end

  defp ongoing_game_ids do
    TicTacToe.ongoing_games |> Enum.map &( String.replace(&1, "tictactoe:", "") )
  end
end
