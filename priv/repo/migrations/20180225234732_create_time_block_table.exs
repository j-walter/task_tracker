defmodule TaskTracker.Repo.Migrations.CreateTimeBlockTable do
  use Ecto.Migration

  def change do
	create table(:time_blocks) do
	  add :task_id, references(:tasks)
	  add :start, :timestamptz
	  add :end, :timestamptz
	  timestamps()
	end	
	create index(:time_blocks, [:task_id])
  end
end
