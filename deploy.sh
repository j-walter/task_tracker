#!/bin/bash

export PORT=5101
export MIX_ENV=prod

INITIAL_DIR=`pwd`


if [ ! $(id -u) = 0 ]; then
  exit 1
fi

POSTGRES_PASSWORD=$(openssl rand -base64 32)
SECRET_KEY_BASE=$(openssl rand -base64 64)

echo "
use Mix.Config
config :task_tracker, TaskTracker.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: \"tasktracker\",
  password: \"$POSTGRES_PASSWORD\",
  database: \"tasktracker\",
  hostname: \"localhost\",
  pool_size: 10

config :task_tracker, TaskTrackerWeb.Endpoint,
    secret_key_base: \"$SECRET_KEY_BASE\"
" > $INITIAL_DIR/config/prod.secret.exs

chown tasktracker:tasktracker "$INITIAL_DIR/config/prod.secret.exs"

su postgres -c "psql -c \"CREATE USER tasktracker;\""
su postgres -c "psql -c \"ALTER USER tasktracker WITH PASSWORD '${POSTGRES_PASSWORD}';\""
su postgres -c "psql -c \"CREATE DATABASE tasktracker;\""
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE tasktracker to tasktracker;\""
su tasktracker -c "
cd "$INITIAL_DIR"

mix deps.get
(cd assets && npm install)
(cd assets && npm rebuild node-sass)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate
ERLANG_COOKIE=\"$(openssl rand -base64 64)\" REPLACE_OS_VARS=true MIX_ENV=prod mix release

mkdir -p ~/www
mkdir -p ~/old

NOW=\$(date +%s)
if [ -d ~/www/tasktracker ]; then
	echo mv ~/www/tasktracker ~/old/\$NOW
	mv ~/www/tasktracker ~/old/\$NOW
fi

mkdir -p ~/www/tasktracker
REL_TAR=\"$INITIAL_DIR/_build/prod/rel/task_tracker/releases/0.0.1/task_tracker.tar.gz\"
echo \"Extracting \$REL_TAR to ~/www/tasktracker\"
(cd ~/www/tasktracker && tar xzf \$REL_TAR)
crontab - <<CRONTAB
@reboot bash $INITIAL_DIR/start.sh
CRONTAB

"
