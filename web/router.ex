defmodule Ref.Router do
  use Ref.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Ref do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/tictactoe/play/:id", TictactoeController, :play
    get "/tictactoe/watch/:id", TictactoeController, :watch
  end

  # Other scopes may use custom stacks.
  # scope "/api", Ref do
  #   pipe_through :api
  # end
end
