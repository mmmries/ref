defmodule Ref.TicTacToeChannel do
  use Phoenix.Channel

  def join("tictactoe:"<>game_id, _auth_msg, socket) do
    IO.puts "someone joined #{game_id}"
    {:ok, %{foo: "bar"}, socket}
  end
end
