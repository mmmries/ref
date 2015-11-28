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
end
