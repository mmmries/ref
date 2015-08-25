defmodule Ref.TicTacToe do
  use GenServer
  @timeout 60_000 #if the game is inactive for 60 seconds it terminates itself

  ## Public Interface
  def join_or_create_game(game_name, user) do
    atom = name2atom(game_name)
    case Process.whereis(atom) do
      nil ->
        {:ok, pid} = GenServer.start(__MODULE__, "tictactoe:#{game_name}", name: atom)
        GenServer.call(pid, {:join, user})
      pid ->
        GenServer.call(pid, {:join, user})
    end
  end

  def move(game_name, move) do
    GenServer.call(name2atom(game_name), {:move, move})
  end

  ## Callbacks
  def init(topic) do
    {:ok, %{
      board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
      players: %{},
      topic: topic,
      whose_turn: "X",
    }, @timeout}
  end

  def handle_call({:join, %{token: token, name: name}}, _from, %{players: players}=state) do
    case Enum.count(players) do
      0 ->
        players = Dict.put(players, token, %{name: name, role: "X"})
        {:reply, {:ok, "X"}, Dict.put(state, :players, players), @timeout}
      1 ->
        players = Dict.put(players, token, %{name: name, role: "O"})
        broadcast_state(state)
        {:reply, {:ok, "O"}, Dict.put(state, :players, players), @timeout}
      _else ->
        {:reply, {:error, "game is full"}, state, @timeout}
    end
  end

  def handle_call({:move, %{token: token, square: square}},_from, state) do
    case Dict.get(state.players, token) do
    nil -> {:reply, {:error, "you are not in this game"}, state}
    player ->
      case player.role == state.whose_turn do
      false -> {:reply, {:error, "not your turn"}, state}
      true ->
        case Enum.at(state.board, square) do
        nil ->
          new_board = List.replace_at(state.board, square, player.role)
          new_state = %{state | board: new_board, whose_turn: next_turn(player.role)}
          broadcast_state(new_state)
          {:reply, {:ok, %{board: new_board, whose_turn: new_state.whose_turn}}, new_state}
        _ ->
          {:reply, {:error, "invalid move, square taken"}, state}
        end
      end
    end
  end

  def handle_call(:stop, _from, state), do: {:stop, :normal, state}

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
  def broadcast_state(%{board: board, topic: topic, whose_turn: whose_turn}) do
    Ref.Endpoint.broadcast! topic, "state", %{board: board, whose_turn: whose_turn}
  end

  def name2atom(game_name), do: "tictactoe:#{game_name}" |> String.to_atom

  def next_turn("X"), do: "O"
  def next_turn("O"), do: "X"
end
