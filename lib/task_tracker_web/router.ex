defmodule TaskTrackerWeb.Router do
  use TaskTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_authentication do
    plug TaskTrackerWeb.Authentication
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", TaskTrackerWeb do
    pipe_through :browser
    pipe_through :browser_authentication
    resources "/users", UserController
    resources "/", UserController
  end

  scope "/", TaskTrackerWeb do
    pipe_through :browser
    get "/register", UserController, :new_self
    post "/register", UserController, :create_self
    get "/signin", AuthController, :new
    post "/signin", AuthController, :create
    get "/signout", AuthController, :delete
    # all authenticated routes below
    pipe_through :browser_authentication
    get "/account", UserController, :edit_self
    post "/account", UserController, :update_self
    resources "/tasks", TaskController
    get "/*path", RedirectController, :index
  end



end
