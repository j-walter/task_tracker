defmodule TaskTracker.Repo.Migrations.UpdateUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :first_name, :string, null: false
      modify :last_name, :string, null: false
      modify :email, :string, null: false
	  add :is_admin, :boolean, default: false
    end
	create unique_index(:users, [:email])
  end
  
end
