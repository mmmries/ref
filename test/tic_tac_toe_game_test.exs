defmodule TicTacToeGameTest do
  use ExUnit.Case

  alias Ref.TicTacToe
  @endpoint Ref.Endpoint
  @game_atom :"tictactoe:test"
  @game_topic "tictactoe:test"

  setup do
    TicTacToe.ongoing_games |> Enum.each fn(game_topic) ->
      game_atom = String.to_atom(game_topic)
      :stopped = GenServer.call(game_atom, :stop)
      :timer.sleep(1)
    end
  end

  test "games are created by joining" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
  end

  test "Only 2 people can join a game" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    assert {:error, "game is full"} == TicTacToe.join_or_create_game(@game_topic, %{token: "t3", name: "snob"})
  end

  test "A user can re-join the game" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t", name: "rob"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
  end

  test "the game state can be requested" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "george"})
    assert {:ok, game_state} = TicTacToe.current_state(@game_topic)
    assert game_state == %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: nil, winner: nil}
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    assert {:ok, game_state} = TicTacToe.current_state(@game_topic)
    assert game_state == %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "X", winner: nil}
  end

  test "players can make a move" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "george"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "bob"})
    {:ok, game_state} = TicTacToe.current_state(@game_topic)
    assert game_state == %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "X", winner: nil}

    assert {:ok, game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 0})
    assert %{board: ["X",nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "O", winner: nil} == game_state
    assert {:ok, game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 1})
    assert game_state == %{board: ["X","O",nil,nil,nil,nil,nil,nil,nil], whose_turn: "X", winner: nil}
  end

  test "games end when a player wins" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "bob"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "rob"})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 0})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 3})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 1})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 4})
    assert {:game_over, game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 2})
    assert game_state == %{board: ["X","X","X","O","O",nil,nil,nil,nil], whose_turn: nil, winner: "X"}
    assert nil == Process.whereis(@game_atom)
  end

  test "games end in cats cradle" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "bob"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t2", name: "rob"})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 0})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 1})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 2})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 3})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 4})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 6})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 5})
    assert {:ok, _game_state} = TicTacToe.move(@game_topic, %{token: "t2", square: 8})
    assert {:game_over, game_state} = TicTacToe.move(@game_topic, %{token: "t1", square: 7})
    assert game_state == %{board: ["X","O","X","O","X","X","O","X","O"], whose_turn: nil, winner: :tie}
    assert nil == Process.whereis(@game_atom)
  end

  test "provides a list of ongoing games" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game(@game_topic, %{token: "t1", name: "bob"})
    assert [@game_topic] = TicTacToe.ongoing_games
    assert {:ok, "X"} = TicTacToe.join_or_create_game("tictactoe:booyah", %{token: "t1", name: "bob"})
    assert ["tictactoe:booyah", @game_topic] = TicTacToe.ongoing_games |> Enum.sort
  end
end
