defmodule Ref.TicTacToe.Smart do
  # Callbacks
  def init, do: :random.seed(:erlang.timestamp)
  def name, do: "Smarty Pants"
  def pick_square(board, my_role) do
    cond do
      take_the_win(board, my_role) -> take_the_win(board, my_role)
      take_a_corner(board) -> take_a_corner(board)
      true -> Ref.TicTacToe.Random.pick_square(board)
    end
  end

  # Private API
  defp take_a_corner(board) do
    [0,2,6,8]
      |> Enum.filter(&( Enum.at(board,&1) == nil ))
      |> List.first
  end

  defp take_the_win([nil,r,r,_,_,_,_,_,_],r), do: 0
  defp take_the_win([nil,_,_,r,_,_,r,_,_],r), do: 0
  defp take_the_win([nil,_,_,_,r,_,_,_,r],r), do: 0
  defp take_the_win([r,nil,r,_,_,_,_,_,_],r), do: 1
  defp take_the_win([_,nil,_,_,r,_,_,r,_],r), do: 1
  defp take_the_win([r,r,nil,_,_,_,_,_,_],r), do: 2
  defp take_the_win([_,_,nil,_,_,r,_,_,r],r), do: 2
  defp take_the_win([_,_,nil,_,r,_,r,_,_],r), do: 2
  defp take_the_win([_,_,_,nil,r,r,_,_,_],r), do: 3
  defp take_the_win([r,_,_,nil,_,_,r,_,_],r), do: 3
  defp take_the_win([_,_,_,r,nil,r,_,_,_],r), do: 4
  defp take_the_win([_,r,_,_,nil,_,_,r,_],r), do: 4
  defp take_the_win([r,_,_,_,nil,_,_,_,r],r), do: 4
  defp take_the_win([_,_,r,_,nil,_,r,_,_],r), do: 4
  defp take_the_win([_,_,_,r,r,nil,_,_,_],r), do: 5
  defp take_the_win([_,_,r,_,_,nil,_,_,r],r), do: 5
  defp take_the_win([_,_,_,_,_,_,nil,r,r],r), do: 6
  defp take_the_win([r,_,_,r,_,_,nil,_,_],r), do: 6
  defp take_the_win([_,_,r,_,r,_,nil,_,_],r), do: 6
  defp take_the_win([_,_,_,_,_,_,r,nil,r],r), do: 7
  defp take_the_win([_,r,_,_,r,_,_,nil,_],r), do: 7
  defp take_the_win([_,_,_,_,_,_,r,r,nil],r), do: 8
  defp take_the_win([_,_,r,_,_,r,_,_,nil],r), do: 8
  defp take_the_win([r,_,_,_,r,_,_,_,nil],r), do: 8
  defp take_the_win(_,_), do: false
end
