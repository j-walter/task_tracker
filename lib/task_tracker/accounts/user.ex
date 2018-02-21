defmodule TaskTracker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TaskTracker.Accounts.User


  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :is_admin, :boolean
    has_many :sessions, TaskTracker.Accounts.Session, on_delete: :delete_all
    has_many :tasks, TaskTracker.Core.Task, on_delete: :nilify_all
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :is_admin])
    |> validate_required([:first_name, :last_name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
