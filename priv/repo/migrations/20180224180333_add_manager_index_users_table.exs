defmodule TaskTracker.Repo.Migrations.AddManagerIndexUsersTable do
  use Ecto.Migration

  def change do
	create index(:users, [:manager_id])
  end
end
