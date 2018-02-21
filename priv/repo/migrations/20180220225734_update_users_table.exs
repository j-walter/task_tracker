defmodule TaskTracker.Repo.Migrations.UpdateSessionsTable do
  use Ecto.Migration

  def change do
	rename table(:tasks), :assignee_user_id, to: :user_id
  end
end
