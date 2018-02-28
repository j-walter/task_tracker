defmodule TaskTracker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias TaskTracker.Repo
  alias TaskTracker.Accounts.User

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :is_admin, :boolean
    belongs_to :manager, User
    has_many :subordinates, User, on_delete: :nilify_all, foreign_key: :manager_id
    has_many :sessions, TaskTracker.Accounts.Session, on_delete: :delete_all
    has_many :tasks, TaskTracker.Core.Task, on_delete: :nilify_all
    timestamps()
  end

  def init do
    %User{id: nil, first_name: "", last_name: "", email: ""}
  end

  def display_name(user) do
    if !!Map.get(user, :id, false) do
      user.first_name <> " " <> user.last_name <> " (" <> user.email <> ")"
    else
      "None"
    end
  end

  def filter_unauthorized_params(authenticated_user, target_user, params) do
    final_user = Map.merge(target_user || %{}, params)
    cond do
      # users cannot modify other user accounts unlesd they are an admin
      !!authenticated_user and !authenticated_user.is_admin and authenticated_user.id != final_user.id ->
        %{}
      true ->
        params
    end
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :is_admin, :manager_id])
    |> validate_required([:first_name, :last_name, :email])
    |> foreign_key_constraint(:manager_id)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def change(%User{} = user) do
    User.changeset(user, %{})
  end

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get!(id) do
    Repo.get_by(User, id: id) |> Repo.preload([:manager, :subordinates])
  end

  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete(%User{} = user) do
    Repo.delete(user)
  end

end
