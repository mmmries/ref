defmodule TicTacToeGameTest do
  use ExUnit.Case
  import Phoenix.ChannelTest

  alias Ref.TicTacToe
  @endpoint Ref.Endpoint

  test "games are created by joining" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game("test", %{token: "t", name: "rob"})
  end

  test "only 2 people can join a game" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game("test_full", %{token: "t", name: "rob"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game("test_full", %{token: "t2", name: "bob"})
    assert {:error, "game is full"} == TicTacToe.join_or_create_game("test_full", %{token: "t3", name: "snob"})
  end

  test "the game state is broadcast when the game is ready" do
    @endpoint.subscribe(self(), "tictactoe:broadtest")
    assert {:ok, "X"} = TicTacToe.join_or_create_game("broadtest", %{token: "t1", name: "george"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game("broadtest", %{token: "t2", name: "bob"})
    assert_broadcast "state", %{board: [nil,nil,nil,nil,nil,nil,nil,nil,nil], whose_turn: "X"}
  end

  test "players can make a move" do
    assert {:ok, "X"} = TicTacToe.join_or_create_game("movetest", %{token: "t1", name: "george"})
    assert {:ok, "O"} = TicTacToe.join_or_create_game("movetest", %{token: "t2", name: "bob"})

    assert {:ok, %{board: board, whose_turn: "O"}} = TicTacToe.move("movetest", %{token: "t1", square: 0})
    assert board == ["X",nil,nil,nil,nil,nil,nil,nil,nil]
    assert {:ok, %{board: board, whose_turn: "X"}} = TicTacToe.move("movetest", %{token: "t2", square: 1})
    assert board == ["X","O",nil,nil,nil,nil,nil,nil,nil]
  end
end
