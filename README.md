Users
When designing the user model, I decided to only assure that the email remains unique using the
dbms and the phoenix changeset validation process

Tasks
When designing the task model, I essentially followed the project requirements as they were stated.
To address the 15-minute increment requirement, I used an HTML5 number input feature that allows you
to set the gap between each increment. To enforce this, I modified the changeset to always round the 
input down to the nearest value that is divisible by 15. 

Sessions
I created the session table as a backing store to the locally maintained phoenix session state
If the app doesn't find an active user session in the local state it will check the db to see 
if the cookie that the client is presenting is associated with a db user. This would handle 
situations where several servers could be delivering responses behind a load balancer (or round-robin dns)

Relationships
This project required me to consider the types of relationships 
each resource type would have with each other. 

- Specifically, users could be associated with multiple sessions and multiple tasks. 
  - I just had to be sure that a deleted user caused all associated sessions to be deleted.
  - This behavior was changed for tasks so the field was just set to null

Authentication
Though the project didn't require us to implement any password functionality it still required a minimal 
authentication pipeline. I implemented this using a plug. The plug checks whether a user has been associated 
with the current session (they completed the login process)

There is a limited amount of admin functionality built into the site that is pretty basic at this point -
technically users can elevate themselves to admin if they post the right form data. Regardless, the beginning of
that functionality is there (which looks like it will help on the next project)
