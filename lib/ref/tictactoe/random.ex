defmodule Ref.TicTacToe.Random do
  # Callbacks
  def init, do: :random.seed(:erlang.timestamp)
  def name, do: "Random AI"
  def pick_square(board) do
    get_playable_indices(board) |> Enum.shuffle |> List.first
  end

  # Internal Logic
  def get_playable_indices(board) do
    Enum.with_index(board)
      |> Enum.filter(fn({nil, _idx}) -> true
                       (_) -> false end)
      |> Enum.map fn({nil,idx}) -> idx end
  end
end
