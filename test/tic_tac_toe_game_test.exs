defmodule TicTacToeGameTest do
  use ExUnit.Case

  alias Ref.TicTacToe

  test "games are created by joining" do
    assert {:ok, _pid} = TicTacToe.join_or_create_game("test", %{token: "t", name: "rob"})
  end

  test "only 2 people can join a game" do
    assert {:ok, pid1} = TicTacToe.join_or_create_game("test_full", %{token: "t", name: "rob"})
    assert {:ok, pid2} = TicTacToe.join_or_create_game("test_full", %{token: "t2", name: "bob"})
    assert pid1 == pid2
    assert {:error, "game is full"} == TicTacToe.join_or_create_game("test_full", %{token: "t3", name: "snob"})
  end
end
