defmodule Ref.TicTacToe do
  use GenServer
  @timeout 60_000 #if the game is inactive for 60 seconds it terminates itself

  ## Public Interface
  def join_or_create_game(game_name, user) do
    game_atom = "tictactoe:#{game_name}" |> String.to_atom
    case Process.whereis(game_atom) do
      nil ->
        GenServer.start(__MODULE__, user, name: game_atom)
      pid ->
        GenServer.call(pid, {:join, user})
    end
  end

  ## Callbacks
  def init(%{token: token, name: name}) do
    players = %{} |> Dict.put(token, %{name: name, role: "X"})
    {:ok, %{
      board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
      players: players,
    }, @timeout}
  end

  def handle_call({:join, %{token: token, name: name}}, _from, %{players: players}=state) do
    case Enum.count(players) do
      1 ->
        players = Dict.put(players, token, %{name: name, role: "O"})
        {:reply, {:ok, self()}, Dict.put(state, :players, players)}
      _else ->
        {:reply, {:error, "game is full"}, state}
    end
  end
end
