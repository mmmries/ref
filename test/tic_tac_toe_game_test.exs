defmodule TicTacToeGameTest do
  use ExUnit.Case

  alias Ref.TicTacToe
  @endpoint Ref.Endpoint
  @game_atom :"tictactoe:test"
  @game_topic "tictactoe:test"

  setup do
    case Process.whereis(@game_atom) do
      nil -> :ok
      _pid ->
        :stopped = GenServer.call(@game_atom, :stop)
        :ok
    end
  end

  test "games are created by joining" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
  end

  test "only 2 people can join a game" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
    assert {:ok, "O", :broadcast, _game_state} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    assert {:error, "game is full"} == TicTacToe.join_or_create_game(@game_topic, %{token: "t3", name: "snob"})
  end

  test "the game state is returned for broadcast when the game is ready" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "george"})
    assert {:ok, "O", :broadcast, game_state} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    assert game_state == %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "X"}
  end

  test "players can make a move" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "george"})
    assert {:ok, "O", :broadcast, game_state} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    assert game_state == %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "X"}

    assert {:ok, game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 0})
    assert %{board: ["X",nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "O"} == game_state
    assert {:ok, game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 1})
    assert game_state == %{board: ["X","O",nil,nil,nil,nil,nil,nil,nil], whose_turn: "X"}
  end
end
