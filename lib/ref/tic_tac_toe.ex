defmodule Ref.TicTacToe do
  use GenServer
  @timeout 60_000 #if the game is inactive for 60 seconds it terminates itself

  ## Public Interface
  def join_or_create_game(game_name, user) do
    game_atom = "tictactoe:#{game_name}" |> String.to_atom
    case Process.whereis(game_atom) do
      nil ->
        {:ok, pid} = GenServer.start(__MODULE__, "tictactoe:#{game_name}", name: game_atom)
        GenServer.call(pid, {:join, user})
      pid ->
        GenServer.call(pid, {:join, user})
    end
  end

  ## Callbacks
  def init(game_id) do
    {:ok, %{
      board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
      game_id: game_id,
      players: %{},
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

  def handle_info(:timeout, state) do
    {:stop, "The game timed out from inactivity", state}
  end
  def handle_info(msg, state) do
    {:stop, "Received unexpected message #{inspect msg}", state}
  end

  ## Private Functions
  def broadcast_state(%{board: board, game_id: gid, whose_turn: whose_turn}) do
    Ref.Endpoint.broadcast! gid, "state", %{board: board, whose_turn: whose_turn}
  end
end
