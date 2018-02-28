defmodule TaskTracker.Repo.Migrations.RemoveTasksTimeTaken do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
	  remove :time_taken
    end
  end
end
