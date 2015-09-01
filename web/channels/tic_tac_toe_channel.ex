defmodule Ref.TicTacToeChannel do
  use Phoenix.Channel

  def join(_topic, %{"just_watching" => true}, socket), do: {:ok, %{}, socket}

  def join(topic, %{"token" => token, "name" => name}, socket) do
    case Ref.TicTacToe.join_or_create_game(topic, %{token: token, name: name}) do
      {:ok, role} -> {:ok, %{role: role}, socket}
      {:ok, role, :broadcast, game_state} ->
        send self(), {:initial_game_state, game_state}
        {:ok, %{role: role}, socket}
      {:error, reason} ->
        {:error, %{message: reason}}
    end
  end

  def handle_in("move", %{"token" => token, "square" => square}, socket) do
    case Ref.TicTacToe.move(socket.topic, %{token: token, square: square}) do
      {:ok, game_state} ->
        broadcast! socket, "state", game_state
        {:noreply, socket}
      {:game_over, game_state, winner} ->
        complete_state = Map.put(game_state, :winner, winner)
        broadcast! socket, "game_over", complete_state
        {:noreply, socket}
      {:error, reason} ->
        {:reply, {:error, %{message: reason}}, socket}
    end
  end

  def handle_info({:initial_game_state, game_state}, socket) do
    broadcast! socket, "state", game_state
    {:noreply, socket}
  end
end
