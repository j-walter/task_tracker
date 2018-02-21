defmodule TaskTrackerWeb.RedirectController do
  use TaskTrackerWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: task_path(conn, :index))
  end

end
