defmodule AdventurerTest do
  use ExUnit.Case, async: true
  alias Ref.Adventurer

  @game_id :test

  test "games are created by joining" do
    assert :ok == Adventurer.join(@game_id, %{name: "me", role: "hero"})
    assert_receive {:status, %{position: {x, y}, health: 100.0, message: message}}
    assert is_integer(x)
    assert is_integer(y)
    assert is_binary(message)
  end

  test "heros can move" do
    :ok = Adventurer.join(@game_id, %{name: "me", role: "hero"})
    assert_receive {:status, %{position: {x, y}}}
    expected_x = x + 1
    assert :ok == Adventurer.move(@game_id, "me", {1,0})
    assert_receive {:status, %{position: {^expected_x, ^y}}}
  end

  test "unknown users cannot move" do
    :ok = Adventurer.join(@game_id, %{name: "me", role: "hero"})
    assert_receive {:status, _status}
    assert {:error, "unknown user"} = Adventurer.move(@game_id, "someone", {1,0})
  end

  test "heros cannot move too far" do
    :ok = Adventurer.join(@game_id, %{name: "me", role: "hero"})
    assert_receive {:status, _status}
    assert {:error, "illegal move"} = Adventurer.move(@game_id, "me", {100, 0})
  end
end
