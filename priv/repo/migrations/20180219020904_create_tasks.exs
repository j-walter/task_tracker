defmodule TaskTracker.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :time_taken, :integer
      add :is_completed, :boolean, default: false, null: false
      add :assignee_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:assignee_user_id])
  end
end
