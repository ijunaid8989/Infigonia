import Config

config :logger, :console, format: "[$level] $message\n"

config :infigonia, Infigonia.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "infigonia_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  timeout: 240_000
