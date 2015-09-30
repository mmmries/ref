defmodule Ref.PageController do
  use Ref.Web, :controller
  alias Ref.TicTacToe

  def index(conn, _params) do
    random_game_id = :rand.uniform |> Float.to_string
    render conn, "index.html", ongoing_games: ongoing_game_ids, random_game_id: random_game_id
  end

  defp ongoing_game_ids do
    TicTacToe.ongoing_games |> Enum.map &( String.replace(&1, "tictactoe:", "") )
  end
end
