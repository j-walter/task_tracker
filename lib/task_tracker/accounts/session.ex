defmodule TaskTracker.Accounts.Session do
  use Ecto.Schema
  alias TaskTracker.Accounts.Session
  @primary_key {:id, :string, autogenerate: false}

  schema "session" do
    belongs_to :user, TaskTracker.Accounts.User, foreign_key: :user_id
    timestamps()
  end

  def normalize(session_id) do
    :crypto.hash(:sha256, session_id || "") |> Base.encode16
  end

  def create(session_id, user) do
    session = TaskTracker.Repo.get_by(Session, id: normalize(session_id))
    if !session do
      TaskTracker.Repo.insert(%Session{id: normalize(session_id), user: user})
    end
  end

  def delete(session_id) do
    session = TaskTracker.Repo.get_by(Session, id: normalize(session_id))
    if !!session do
      TaskTracker.Repo.delete(%{id: normalize(session_id)})
    end
  end

  def get_user(session_id) do
    session = TaskTracker.Repo.get(Session, normalize(session_id))
    if !!session do
       session |> TaskTracker.Repo.preload(:user) |> Map.get(:user)
    end
  end

end