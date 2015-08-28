defmodule Ref.Router do
  use Ref.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Ref do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/tictactoe/tutorial", TictactoeController, :tutorial
    get "/tictactoe/play/:id", TictactoeController, :play
    get "/tictactoe/watch/:id", TictactoeController, :watch
  end
end
