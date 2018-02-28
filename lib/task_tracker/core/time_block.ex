defmodule TaskTracker.Core.TimeBlock do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias TaskTracker.Core.TimeBlock
  alias TaskTracker.Accounts.User
  alias TaskTracker.Core.Task
  alias TaskTracker.Repo

  schema "time_blocks" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    belongs_to :task, Task, foreign_key: :task_id
    timestamps()
  end

  def changeset(%TimeBlock{} = time_block, attrs) do
    time_block
    |> cast(attrs, [:start, :end, :task_id])
    |> foreign_key_constraint(:task_id)
    |> validate_required([:task_id, :start])
  end

  def change(%TimeBlock{} = time_block) do
    TimeBlock.changeset(time_block, %{})
  end

  def create(attrs \\ %{}) do
    %TimeBlock{}
    |> TimeBlock.changeset(attrs)
    |> Repo.insert()
  end

  def query_user_tasks(query, user) do
    from time_blocks in query,
      join: task in assoc(time_blocks, :task),
      where: task.user_id == ^user.id,
      preload: [task: task]
  end

  def query_user_and_subordinate_tasks(query, user) do
    related_users = [user.id | Enum.map(Map.get(User.get!(user.id), :subordinates) || [], fn(x) -> x.id end)]
    from time_blocks in query,
      join: task in assoc(time_blocks, :task),
      where: task.user_id in ^related_users,
      preload: [task: task]
  end

  def query_by_id(query, id) do
    if !!id do
     from time_blocks in query,
        where: time_blocks.id == ^id
    else
      from time_blocks in query
    end
  end

  def query_by_task_id(query, task_id) do
    from time_blocks in query,
      join: task in assoc(time_blocks, :task),
      where: time_blocks.task_id == ^task_id
  end

  def get!(id) do
    if is_integer(id) do
      Repo.get_by(TimeBlock, id: id)
    else
      nil
    end
  end

  def get!(action, params, authenticated_user, task_id, id) do
    list = get_all(action, params, authenticated_user, task_id, id)
    if Enum.empty?(list) do
      nil
    else
      List.first(list)
    end
  end

  def get_all(action, params, authenticated_user, task_id, id) do
    user = authenticated_user
    task = Task.get!(task_id) || %{}
    cond do
      # only users that own the task can create new time blocks for it - also they cannot create additionals ones if one is incomplete
      action === "create" and user.id === Map.get(task, :user_id, 0) and (!Map.get(task, :current_time_block_id) or !!Map.get(TimeBlock.get!(Map.get(task, :current_time_block_id) || 0) || %{}, :end, nil)) ->
        [true]
      action in ["list", "read"] ->
        TimeBlock
        |> query_by_id(id)
        |> query_by_task_id(task_id)
        |> query_user_and_subordinate_tasks(user)
        |> Repo.all
      action in ["update", "delete"] ->
        TimeBlock
        |> query_by_id(id)
        |> query_by_task_id(task_id)
        |> query_user_tasks(user)
        |> Repo.all
      true ->
        []
    end
  end

  def update(%TimeBlock{} = time_block, attrs) do
    time_block
    |> TimeBlock.changeset(attrs)
    |> Repo.update()
  end

  def delete(%TimeBlock{} = time_block) do
    Repo.delete(time_block)
  end

end
