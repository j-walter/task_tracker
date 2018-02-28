defmodule TaskTrackerWeb.UserController do
  use TaskTrackerWeb, :controller
  alias TaskTracker.Accounts
  alias TaskTracker.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    users = [User.init | Accounts.list_users()]
    changeset = User.change(%User{manager: nil})
    render(conn, "new.html", changeset: changeset, users: users)
  end

  defdelegate new_self(term, opts \\ []), to: __MODULE__, as: :new

  def create(conn, %{"user" => user_params}) do
    users = [User.init | Accounts.list_users()]
    user_params = User.filter_unauthorized_params(get_session(conn, "user"), nil, user_params)
    case User.create(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, users: users)
    end
  end

  defdelegate create_self(term, opts \\ []), to: __MODULE__, as: :create

  def show(conn, %{"id" => id}) do
    user = User.get!(id)
    render(conn, "show.html", user: user)
  end

  defdelegate show_self(term, opts \\ []), to: __MODULE__, as: :show

  def edit(conn, %{"id" => id}) do
    user = User.get!(id)
    users = [User.init | Accounts.list_users()]
    changeset = User.change(user)
    render(conn, "edit.html", user: user, changeset: changeset, users: users)
  end

  defdelegate edit_self(term, opts \\ []), to: __MODULE__, as: :edit

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = User.get!(id)
    users = [User.init | Accounts.list_users()]
    user_params = User.filter_unauthorized_params(get_session(conn, "user"), user, user_params)
    case User.update(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, users: users)
    end
  end

  defdelegate update_self(term, opts \\ []), to: __MODULE__, as: :update

  def delete(conn, %{"id" => id}) do
    if Map.get(get_session(conn, "user"), :is_admin, false) do
      user = User.get!(id)
      {:ok, _user} = User.delete(user)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: user_path(conn, :index))
    end
  end

end
