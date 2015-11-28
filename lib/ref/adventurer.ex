defmodule Ref.Adventurer do
  use GenServer
  @timeout 120_000

  def join(game_id, user) do
    {:ok, pid} = case Process.whereis(game_id) do
      nil ->
        GenServer.start(__MODULE__, game_id, name: game_id)
      pid when is_pid(pid) ->
        {:ok, pid}
    end

    GenServer.call(pid, {:join, user})
  end

  def move(game_id, name, movement) do
    GenServer.call(game_id, {:move, name, movement})
  end

  ## Callbacks
  def init(game_id) do
    {:ok, %{
      game_id: game_id,
      players: %{},
    }, @timeout}
  end

  def handle_call({:join, %{name: name}=player}, {pid, _ref}, %{players: players}=state) do
    player = initialize_player(player, pid)
    send_player_status(player, "Your adventure begins...")
    new_players = Map.put(players, name, player)
    {:reply, :ok, %{state | players: new_players}, @timeout}
  end

  def handle_call({:move, name, movement}, _from, %{players: players}=state) do
    case attempt_move(players, name, movement) do
      {:ok, new_player} ->
        send_player_status(new_player, "You have moved")
        {:reply, :ok, %{state | players: Map.put(state.players, name, new_player)}, @timeout}
      {:error, reason} ->
        {:reply, {:error, reason}, state, @timeout}
    end
  end

  ## Private Functions
  defp attempt_move(players, name, movement) do
    case Map.get(players, name) do
      nil -> {:error, "unknown user"}
      player -> attempt_move(player, movement)
    end
  end
  defp attempt_move(%{position: {x,y}}=player, {dx,dy}) do
    if legal_move?(player, {dx, dy}) do
      {:ok, %{player | position: {x+dx, y+dy}}}
    else
      {:error, "illegal move"}
    end
  end

  defp initialize_player(%{name: name, role: "hero"}, pid) do
    %{name: name, role: "hero", pid: pid, position: {0,0}, health: 100.0}
  end

  defp legal_move?(%{role: "hero"}, {dx, dy}) when dx > 1 or dy > 1 or dx < -1 or dy < -1, do: false
  defp legal_move?(_player,_movement), do: true

  defp send_player_status(%{pid: pid, health: h, position: p}, message) do
    send pid, {:status, %{health: h, position: p, message: message}}
  end
end
