defmodule TaskTracker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
	  add :is_admin, :boolean
      timestamps()
    end
    create unique_index(:users, [:email])
  end
end
