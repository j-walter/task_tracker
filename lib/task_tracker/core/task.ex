defmodule TaskTracker.Core.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias TaskTracker.Core.Task


  schema "tasks" do
    field :description, :string
    field :is_completed, :boolean, default: false
    field :time_taken, :integer
    field :title, :string
    belongs_to :user, TaskTracker.Accounts.User, foreign_key: :user_id

    timestamps()
  end

  def clean_time_taken(task) do
    if !Enum.empty?(Map.get(task, :changes, %{})) do
      Map.merge(task, %{changes: Map.merge(Map.get(task, :changes), %{time_taken: Kernel.max(0, 15 * Kernel.trunc((Map.get(Map.get(task, :changes), :time_taken) || 0) / 15))})})
    else
      task
    end
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    IO.inspect(attrs)
    task
    |> cast(attrs, [:title, :description, :time_taken, :is_completed, :user_id])
    |> validate_required([:title])
    |> clean_time_taken
  end
end
