defmodule TaskTrackerWeb.AuthController do
  use TaskTrackerWeb, :controller

  def new(conn, _params) do
    if !get_session(conn, "user") do
      render conn, "new.html"
    else
      redirect(conn, to: task_path(conn, :index))
    end
  end

  def create(conn, params) do
    user = TaskTracker.Accounts.Auth.login(params)
    if !!user do
      TaskTracker.Accounts.Session.create(Map.get(conn.cookies, "sid"), user)
      put_session(conn, "user", user)
      |> redirect(to: task_path(conn, :index))
    else
      redirect(conn, to: auth_path(conn, :new))
    end
  end

  def delete(conn, _params) do
    user = get_session(conn, "user")
    if !!user do
      TaskTracker.Accounts.Session.delete(Map.get(conn.cookies, "sid"))
      clear_session(conn)
      |> redirect(to: auth_path(conn, :new))
    else
      redirect(conn, to: auth_path(conn, :new))
    end
  end

end
