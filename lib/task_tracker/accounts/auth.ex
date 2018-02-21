defmodule TaskTracker.Accounts.Auth do
  alias TaskTracker.Accounts.Auth

  def login(params) do
    email = Map.get(params, "email")
    #password = Map.get(params, "password")
    if !!email do
      TaskTracker.Repo.get_by(TaskTracker.Accounts.User, email: String.downcase(email))
    else
      nil
    end
  end

end
