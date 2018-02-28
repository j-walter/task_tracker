defmodule TaskTracker.Core.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias TaskTracker.Core.Task
  alias TaskTracker.Repo
  alias TaskTracker.Accounts.User
  alias TaskTracker.Core.TimeBlock

  schema "tasks" do
    field :description, :string
    field :is_completed, :boolean, default: false
    field :title, :string
    belongs_to :user, User, foreign_key: :user_id
    has_many :time_blocks, TimeBlock, on_delete: :delete_all
    field :current_time_block_id, :integer, virtual: true
    timestamps()
  end

  def filter_unauthorized_params(authenticated_user, target_task, params) do
    user = authenticated_user
    final_task = Map.merge(target_task || %{}, params)
    cond do
      # remove all arguments except completed flag if the current user isn't the manager of the associated task user
      !!user.is_admin and !!final_task and !!Map.get(final_task, "user_id", nil) and Map.get(User.get!(Map.get(final_task, "user_id", 0)), :manager_id, 0) != user.id ->
        %{is_completed: Map.get(final_task, :is_completed, false)}
      true ->
        params
    end
  end

  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:title, :description, :is_completed, :user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_required([:title])
  end

  def change(%Task{} = task) do
    Task.changeset(task, %{})
  end

  def create(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def query_user_tasks(query, user) do
    from tasks in query,
      where: is_nil(tasks.user_id) or tasks.user_id == ^user.id,
      left_join: user in assoc(tasks, :user),
      preload: [user: user]
  end

  def query_user_and_subordinate_tasks(query, user) do
    related_users = [user.id | Enum.map(Map.get(User.get!(user.id), :subordinates) || [], fn(x) -> x.id end)]
    from tasks in query,
      where: is_nil(tasks.user_id) or tasks.user_id in ^related_users,
      left_join: user in assoc(tasks, :user),
      preload: [user: user]
  end

  def query_subordinate_tasks(query, user) do
    subordinates = Enum.map(Map.get(User.get!(user.id), :subordinates) || [], fn(x) -> x.id end)
    from tasks in query,
      where: is_nil(tasks.user_id) or tasks.user_id in ^subordinates,
      left_join: user in assoc(tasks, :user),
      preload: [user: user]
  end

  def query_add_current_time_block(query) do
    from tasks in query,
      left_join: time_block in TimeBlock, on: tasks.id == time_block.task_id and is_nil(time_block.end),
      select: %{tasks | current_time_block_id: time_block.id}
  end

  def query_by_id(query, id) do
    if !!id do
      from tasks in query,
        where: tasks.id == ^id
    else
      from tasks in query
    end
  end

  def get!(id) do
    tasks = Task
    |> query_by_id(id)
    |> query_add_current_time_block
    |> Repo.all
    if Enum.empty?(tasks) do
      nil
    else
      List.first(tasks)
    end
  end

  def get!(action, params, authenticated_user, id) do
    list = get_all(action, params, authenticated_user, id)
    if Enum.empty?(list) do
      nil
    else
      List.first(list)
    end
  end

  def get_all(action, params, authenticated_user, id) do
    user = authenticated_user
    cond do
      # during create you need to allow empty params for the intial blank task creation view
      action === "create" and (Enum.empty?(params) or user.id === Map.get(User.get!(Map.get(params, "user_id", 0)) || %{}, :manager_id, 0))  ->
        [true]
      action in ["update", "list", "read"] ->
        Task
        |> query_user_and_subordinate_tasks(user)
        |> query_by_id(id)
        |> query_add_current_time_block
        |> Repo.all
      action in ["delete"] ->
        Task
        |> query_add_current_time_block
        |> query_subordinate_tasks(user)
        |> query_by_id(id)
        |> Repo.all
      true ->
        []
    end
  end

  def update(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Task{} = task) do
    Repo.delete(task)
  end

end
