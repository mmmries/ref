defmodule Ref.PageControllerTest do
  use Ref.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "tic-tac-toe"
  end
end
