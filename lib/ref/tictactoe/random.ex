defmodule Ref.TicTacToe.Random do
  # Callbacks
  def init, do: :random.seed(:erlang.timestamp)
  def name, do: "Random AI"
  def pick_square(board, _my_role), do: pick_square(board)
  def pick_square(board) do
    board
      |> get_playable_indices
      |> Enum.shuffle
      |> List.first
  end

  # Internal Logic
  def get_playable_indices(board) do
    Enum.with_index(board)
      |> Enum.filter(fn({nil, _idx}) -> true
                       (_) -> false end)
      |> Enum.map fn({nil,idx}) -> idx end
  end
end
