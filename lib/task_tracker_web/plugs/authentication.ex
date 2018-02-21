defmodule TaskTrackerWeb.Authentication do
  @behaviour Plug
  import Plug.Conn

  def init(default) do
    default
  end

  def call(conn, _default) do
    # try pulling the user out of the current session
    # otherwise call to get_user and try to pull the session state from the db
    user = get_session(conn, "user") || get_db_session_user(conn)
    if !!user do
      conn
    else
      Phoenix.Controller.redirect(conn, to: TaskTrackerWeb.Router.Helpers.auth_path(conn, :new))
    end
  end

  defp get_db_session_user(conn) do
    session_id = Map.get(conn.cookies,  "sid")
    if !!session_id do
      TaskTracker.Accounts.Session.get_user(session_id)
    end
  end

  defp authenticated?(conn) do
    !!(get_session(conn, "user") || get_user(conn))
  end

end
