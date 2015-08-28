defmodule Ref.PageController do
  use Ref.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
