defmodule TaskTrackerWeb.Authentication do
  @behaviour Plug
  import Plug.Conn
  alias TaskTracker.Accounts.Session

  def init(default) do
    default
  end

  def call(conn, _default) do
    # try pulling the user out of the current session
    # otherwise call to get_user and try to pull the session state from the db
    conn = if !!get_session(conn, "user"), do: conn, else: get_db_session_user(conn)
    if !!get_session(conn, "user") do
      conn
    else
      Phoenix.Controller.redirect(conn, to: TaskTrackerWeb.Router.Helpers.auth_path(conn, :new))
    end
  end

  defp get_db_session_user(conn) do
    user = Session.get_user(Map.get(conn.cookies,  "sid"))
    if !!user do
      put_session(conn, "user", user)
    else
      conn
    end
  end

end
