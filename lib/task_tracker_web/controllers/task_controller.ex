defmodule TaskTrackerWeb.TaskController do
  use TaskTrackerWeb, :controller

  alias TaskTracker.Core.Task
  alias TaskTracker.Accounts.User

  def index(conn, _params) do
    tasks = Task.get_all("list", %{}, get_session(conn, "user"), nil)
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    task = Task.get!("create", %{}, get_session(conn, "user"), nil)
    if !task do
      Plug.Conn.send_resp(conn, 403, "")
    else
      changeset = Task.change(%Task{})
      subordinates = Map.get(User.get!(get_session(conn, "user").id) || %{}, :subordinates, [])
      render(conn, "new.html", changeset: changeset, subordinates: subordinates)
    end
  end

  def create(conn, %{"task" => params}) do
    task = Task.get!("create", params, get_session(conn, "user"), nil)
    if !task do
      Plug.Conn.send_resp(conn, 403, "")
    else
      subordinates = Map.get(User.get!(get_session(conn, "user").id) || %{}, :subordinates, [])
      case Task.create(Task.filter_unauthorized_params(get_session(conn, "user"), nil, params)) do
        {:ok, task} ->
          conn
          |> put_flash(:info, "Task created successfully.")
          |> redirect(to: task_path(conn, :show, task))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, subordinates: subordinates)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    task = Task.get!("read", %{}, get_session(conn, "user"), id)
    if !task do
      Plug.Conn.send_resp(conn, 403, "")
    else
      render(conn, "show.html", task: task)
    end
  end

  def edit(conn, %{"id" => id}) do
    task = Task.get!("update", %{}, get_session(conn, "user"), id)
    if !task do
      Plug.Conn.send_resp(conn, 403, "")
    else
      changeset = Task.change(task)
      subordinates = Map.get(User.get!(get_session(conn, "user").id) || %{}, :subordinates, [])
      render(conn, "edit.html", task: task, changeset: changeset, subordinates: subordinates)
    end
  end

  def update(conn, %{"id" => id, "task" => params}) do
    task = Task.get!("update", params, get_session(conn, "user"), id)
    if !task do
      Plug.Conn.send_resp(conn, 403, "")
    else
      case Task.update(task, Task.filter_unauthorized_params(get_session(conn, "user"), task, params)) do
        {:ok, task} ->
          conn
          |> put_flash(:info, "Task updated successfully.")
          |> redirect(to: task_path(conn, :show, task))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", task: task, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Task.get!("delete", %{}, get_session(conn, "user"), id)
    if !task do
      Plug.Conn.send_resp(conn, 403, "")
    else
    {:ok, _task} = Task.delete(task)
      conn
      |> put_flash(:info, "Task deleted successfully.")
      |> redirect(to: task_path(conn, :index))
    end
  end
end
