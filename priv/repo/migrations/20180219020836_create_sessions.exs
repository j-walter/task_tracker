defmodule TaskTracker.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:session, primary_key: false) do
      add :id, :string, primary_key: true
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:session, [:id, :user_id])
  end
end
