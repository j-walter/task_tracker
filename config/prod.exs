use Mix.Config

config :task_tracker, TaskTrackerWeb.Endpoint,
server: true,
  load_from_system_env: true,
  url: [host: "tasktracker.loopback.onl", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  root: "."
config :logger, level: :info
config :phoenix, :stacktrace_depth, 20

import_config "prod.secret.exs"
