defmodule Ref.MatchupChannel do
  use Phoenix.Channel

  def join("matchup:lobby", _, socket), do: {:ok, socket}

  def handle_in("request:tictactoe", %{token: token, name: name}, socket) do
    send self, {:echo, socket}
    #Ref.MatchMaker.find_a_game_for(socket, :tictactoe)
    {:ok, socket}
  end

  # TODO implement a terminate/2 function so we can skip trying to match up requests from websockets which have dropped

  def handle_info({:echo, socket}, _socket) do
    push socket, "game_found", %{topic: "tictactoe:WAT"}
    {:noreply, socket}
  end
end
