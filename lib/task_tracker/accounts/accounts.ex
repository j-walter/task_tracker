defmodule TaskTracker.Accounts do

  import Ecto.Query, warn: false
  alias TaskTracker.Repo
  alias TaskTracker.Accounts.User

  def list_users do
    Repo.all(User)
  end


end
