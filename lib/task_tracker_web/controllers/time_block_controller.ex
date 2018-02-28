defmodule TaskTrackerWeb.TimeBlockController do
  use TaskTrackerWeb, :controller

  alias TaskTracker.Core.TimeBlock

  def index(conn, %{"task_id" => task_id}) do
    time_blocks = TimeBlock.get_all("list", %{}, get_session(conn, "user"), task_id, nil)
    json put_status(conn, :ok), time_blocks
  end

  def create(conn, %{"task_id" => task_id, "time_block" => params}) do
    time_block = TimeBlock.get!("create", params, get_session(conn, "user"), task_id, nil)
    if !time_block do
      json put_status(conn, :forbidden), %{}
    else
      case TimeBlock.create(Map.merge(params, Map.new(%{task_id: task_id}, fn {key, value} -> {Kernel.to_string(key), Kernel.to_string(value)} end))) do
        {:ok, time_block} ->
          conn
          |> redirect(to: time_block_path(conn, :show, task_id, time_block))
        {:error, %Ecto.Changeset{} = changeset} ->
          json put_status(conn, :bad_request), %{}
      end
    end
  end

  def show(conn, %{"task_id" => task_id, "id" => id}) do
    time_block = TimeBlock.get!("read", %{}, get_session(conn, "user"), task_id, id)
    if !time_block do
      json put_status(conn, :forbidden), %{}
    else
      json put_status(conn, :ok), time_block
    end
  end

  def update(conn, %{"task_id" => task_id, "id" => id, "time_block" => params}) do
    time_block = TimeBlock.get!("update", params, get_session(conn, "user"), task_id, id)
    if !time_block do
      json put_status(conn, :forbidden), %{}
    else
      case TimeBlock.update(time_block, Map.merge(params, Map.new(%{task_id: task_id, id: id}, fn {key, value} -> {Kernel.to_string(key), Kernel.to_string(value)} end))) do
        {:ok, time_block} ->
          conn
          |> redirect(to: time_block_path(conn, :show, task_id, time_block))
        {:error, %Ecto.Changeset{} = changeset} ->
          json put_status(conn, :bad_request), %{}
      end
    end
  end

  def delete(conn, %{"task_id" => task_id, "id" => id}) do
    time_block = TimeBlock.get!("delete", %{}, get_session(conn, "user"), task_id, id)
    if !time_block do
      json put_status(conn, :forbidden), %{}
    else
      {:ok, _task} = TimeBlock.delete(time_block)
      conn
      |> redirect(to: time_block_path(conn, :index, task_id))
    end
  end

end
