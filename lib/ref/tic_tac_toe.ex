defmodule Ref.TicTacToe do
  use GenServer
  @timeout 600_000 # timeout if the game is inactive for 10min

  ## Public Interface
  def current_state(topic) do
    atom = String.to_atom(topic)
    GenServer.call(atom, :current_state)
  end

  def join_or_create_game(topic, user) do
    atom = String.to_atom(topic)
    case Process.whereis(atom) do
      nil ->
        {:ok, pid} = GenServer.start(__MODULE__, topic, name: atom)
        GenServer.call(pid, {:join, user})
      pid ->
        GenServer.call(pid, {:join, user})
    end
  end

  def move(topic, move) do
    GenServer.call(String.to_atom(topic), {:move, move})
  end

  def ongoing_games do
    Process.registered
      |> Enum.map(&Atom.to_string/1)
      |> Enum.filter(fn("tictactoe:"<>_rest) -> true
                       (_) -> false
                     end)
  end

  ## Callbacks
  def init(topic) do
    {:ok, %{
      board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
      players: %{},
      topic: topic,
      whose_turn: nil,
      winner: nil,
    }, @timeout}
  end

  def handle_call(:current_state, _from, state) do
    {:reply, {:ok, public_state(state)}, state, @timeout}
  end

  def handle_call({:join, %{token: token, name: name}}, _from, %{players: players}=state) do
    case Dict.get(players, token) do
      %{role: role} ->
        {:reply, {:ok, role}, state, @timeout}
      nil -> case Enum.count(players) do
        0 ->
          players = Dict.put(players, token, %{name: name, role: "X"})
          new_state = %{state | players: players}
          {:reply, {:ok, "X"}, new_state, @timeout}
        1 ->
          players = Dict.put(players, token, %{name: name, role: "O"})
          new_state = %{state | players: players, whose_turn: "X"}
          {:reply, {:ok, "O"}, new_state, @timeout}
        _else ->
          {:reply, {:error, "game is full"}, state, @timeout}
        end
    end
  end

  def handle_call({:move, %{token: token, square: square}},_from, state) do
    case Dict.get(state.players, token) do
    nil -> {:reply, {:error, "you are not in this game"}, state, @timeout}
    player ->
      case player.role == state.whose_turn do
      false -> {:reply, {:error, "not your turn"}, state, @timeout}
      true ->
        case Enum.at(state.board, square) do
        nil ->
          new_board = List.replace_at(state.board, square, player.role)
          case game_over?(new_board) do
          false ->
            new_state = %{state | board: new_board, whose_turn: next_turn(player.role)}
            broadcast_state(new_state)
            {:reply, {:ok, public_state(new_state)}, new_state, @timeout}
          :tie ->
            new_state = %{state | board: new_board, whose_turn: nil, winner: :tie}
            broadcast_state(new_state)
            {:stop, :normal, {:game_over, public_state(new_state)}, new_state}
          winner ->
            new_state = %{state | board: new_board, whose_turn: nil, winner: winner}
            broadcast_state(new_state)
            {:stop, :normal, {:game_over, public_state(new_state)}, new_state}
          end
        _ ->
          {:reply, {:error, "invalid move, square taken"}, state, @timeout}
        end
      end
    end
  end

  def handle_call(:stop, _from, state), do: {:stop, :normal, :stopped, state}

  def handle_info(:timeout, state) do
    {:stop, "The game timed out from inactivity", state}
  end
  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end
  def handle_info(msg, state) do
    {:stop, "Received unexpected message #{inspect msg}", state}
  end

  ## Private Functions
  defp broadcast_state(state) do
    event = case state.winner do
      nil -> "state"
      _ -> "game_over"
    end
    Ref.Endpoint.broadcast state.topic, event, public_state(state)
  end

  defp game_over?([x,x,x,_,_,_,_,_,_]) when x != nil, do: x
  defp game_over?([_,_,_,x,x,x,_,_,_]) when x != nil, do: x
  defp game_over?([_,_,_,_,_,_,x,x,x]) when x != nil, do: x
  defp game_over?([x,_,_,x,_,_,x,_,_]) when x != nil, do: x
  defp game_over?([_,x,_,_,x,_,_,x,_]) when x != nil, do: x
  defp game_over?([_,_,x,_,_,x,_,_,x]) when x != nil, do: x
  defp game_over?([x,_,_,_,x,_,_,_,x]) when x != nil, do: x
  defp game_over?([_,_,x,_,x,_,x,_,_]) when x != nil, do: x
  defp game_over?(board) do
    case Enum.any?(board, &( &1 == nil) ) do
      true -> false
      false -> :tie
    end
  end

  defp next_turn("X"), do: "O"
  defp next_turn("O"), do: "X"

  defp public_state(%{board: board, whose_turn: whose_turn, winner: winner}) do
    %{board: board, whose_turn: whose_turn, winner: winner}
  end
end
