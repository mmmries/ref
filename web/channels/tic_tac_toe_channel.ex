defmodule Ref.TicTacToeChannel do
  use Phoenix.Channel

  def join("tictactoe:"<>game_id, %{"token" => token, "name" => name}, socket) do
    {:ok, %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil]}, socket}
  end

  def handle_in("move", %{"token" => token, "square" => square}, socket) do
    broadcast! socket, "state", %{board: ["X",nil,nil,nil,nil,nil,nil,nil,nil]}
    {:noreply, socket}
  end
end
