defmodule Ref.TicTacToe.Random do
  use GenServer
  @name "Random AI"

  # Public API
  def start(topic, sleep_between_moves \\ 0) do
    GenServer.start(__MODULE__, {topic, sleep_between_moves})
  end

  # Callbacks
  def init({topic, sleep_between_moves}) do
    :rand.seed(:exs1024)
    token = :rand.uniform |> Float.to_string
    {:ok, role} = Ref.TicTacToe.join_or_create_game(topic, %{token: token, name: @name})
    Ref.Endpoint.subscribe(self, topic)
    {:ok, %{topic: topic, token: token, role: role, sleep_between_moves: sleep_between_moves}}
  end

  def handle_info(%{event: "state", payload: %{board: board, whose_turn: role}}, %{role: role, sleep_between_moves: sleep_between_moves}=state) do
    %{token: token, topic: topic} = state
    idx = pick_index(board)
    :timer.sleep(sleep_between_moves)
    case Ref.TicTacToe.move(topic, %{token: token, square: idx}) do
      {:ok, _game_state} -> nil
      {:game_over, _game_state} -> nil
      {:error, "not your turn"} -> nil
    end
    {:noreply, state}
  end

  def handle_info(%{event: "game_over"}, state) do
    {:stop, :normal, state}
  end

  def handle_info(msg, state) do
    IO.puts "#{@name} received a message"
    IO.inspect msg
    {:noreply, state}
  end

  # Private API
  def get_playable_indices(board) do
    Enum.with_index(board)
      |> Enum.filter(fn({nil, _idx}) -> true
                       (_) -> false end)
      |> Enum.map fn({nil,idx}) -> idx end
  end

  def pick_index(board) do
    get_playable_indices(board) |> Enum.shuffle |> List.first
  end
end
