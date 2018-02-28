defmodule TaskTracker.Accounts.Auth do

  def login(params) do
    email = Map.get(params, "email") || ""
    #password = Map.get(params, "password")
    if !!email do
      user = TaskTracker.Repo.get_by(TaskTracker.Accounts.User, email: String.downcase(email))
      |> TaskTracker.Repo.preload([:manager, :subordinates])
      # explicitly grant the first two users admin rights
       if !!user and user.id <= 2 do
         user |> Map.merge(%{is_admin: true})
       else
          user
       end
    else
      nil
    end
  end

end
