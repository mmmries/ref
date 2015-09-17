defmodule Ref.TicTacToe.AI do
  use GenServer
  require Logger

  # Public API
  def start(topic, ai_module, sleep_between_moves \\ 0) do
    GenServer.start(__MODULE__, {topic, ai_module, sleep_between_moves})
  end

  # Callbacks
  def init({topic, ai_module, sleep_between_moves}) do
    token = :rand.uniform |> Float.to_string
    name = apply(ai_module, :name, [])
    {:ok, role} = Ref.TicTacToe.join_or_create_game(topic, %{token: token, name: name})
    Ref.Endpoint.subscribe(self, topic)
    apply(ai_module, :init, [])
    {:ok, %{ai_module: ai_module, topic: topic, token: token, role: role, sleep_between_moves: sleep_between_moves}}
  end

  def handle_info(%{event: "state"}=game_state, state) do
    %{payload: %{board: board}} = game_state
    %{token: token, topic: topic} = state
    square = apply(state.ai_module, :pick_square, [board, state.role])
    :timer.sleep(state.sleep_between_moves)
    case Ref.TicTacToe.move(topic, %{token: state.token, square: square}) do
      {:ok, _game_state} -> nil
      {:game_over, _game_state} -> nil
      {:error, "not your turn"} -> nil
      {:error, "invalid move, square taken"} -> nil
    end
    {:noreply, state}
  end

  def handle_info(%{event: "game_over"}, state) do
    {:stop, :normal, state}
  end

  def handle_info(msg, state) do
    Logger.error "Received an unexpected message: #{inspect msg}"
    {:noreply, state}
  end
end
