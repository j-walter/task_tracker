defmodule TaskTrackerWeb.Router do
  use TaskTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :cookie_auth do
    plug TaskTrackerWeb.Authentication
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  scope "/api", TaskTrackerWeb do
    pipe_through :api
    pipe_through :cookie_auth
    resources "/tasks/:task_id/time_blocks", TimeBlockController
  end

  scope "/admin", TaskTrackerWeb do
    pipe_through :browser
    pipe_through :cookie_auth
    resources "/users", UserController
    resources "/", UserController
  end

  scope "/", TaskTrackerWeb do
    pipe_through :browser
    get "/register", UserController, :new_self
    post "/register", UserController, :create_self
    # all authenticated routes below
    get "/signin", AuthController, :new
    post "/signin", AuthController, :create
    pipe_through :cookie_auth
    get "/signout", AuthController, :delete
    get "/account/:id", UserController, :show_self
    get "/account/:id/edit", UserController, :edit_self
    post "/account/:id/edit", UserController, :update_self
    resources "/tasks", TaskController
    get "/*path", RedirectController, :index
  end


end
