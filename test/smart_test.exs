defmodule Ref.SmartTest do
  use ExUnit.Case, async: true
  alias Ref.TicTacToe.Smart

  test "it always takes a winning move" do
    assert 1 == Smart.pick_square(["X",nil,"X","O",nil,nil,nil,nil,nil], "X")
  end

  test "it prefers the top-left corner" do
    assert 0 == Smart.pick_square([nil,nil,nil,nil,nil,nil,nil,nil,nil], "X")
  end

  test "I guess I'll take the top-right corner" do
    assert 2 == Smart.pick_square(["X",nil,nil,nil,nil,nil,nil,nil,nil], "O")
  end

  test "I guess I'll take the bottom-left corner" do
    assert 6 == Smart.pick_square(["X",nil,"O",nil,nil,nil,nil,nil,nil], "X")
  end

  test "I guess I'll take the bottom-right corner" do
    assert 8 == Smart.pick_square(["X",nil,"O",nil,nil,nil,"X",nil,nil], "O")
  end

  test "It falls back to playing random" do
    assert Smart.pick_square(["X",nil,"O",nil,nil,nil,"O",nil,"X"],"X") in [1,3,4,5,7]
  end
end
