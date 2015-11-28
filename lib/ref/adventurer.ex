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

  ## Callbacks
  def init(game_id) do
    {:ok, %{
      game_id: game_id,
      players: %{},
    }, @timeout}
  end

  def handle_call({:join, %{name: name, role: "hero"}=player}, {pid, _ref}, %{players: players}=state) do
    player = Map.put(player, :pid, pid)
    new_players = Map.put(players, name, player)
    initialize_player(player)
    {:reply, :ok, %{state | players: new_players}, @timeout}
  end

  ## Private Functions
  def initialize_player(%{pid: pid}) do
    send pid, {:status, %{position: {0,0}, health: 100.0, message: "ohai"}}
  end
end
