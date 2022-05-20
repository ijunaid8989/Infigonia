import Config

config :logger, level: :info

config :infigonia, Infigonia.Repo,
  url: System.fetch_env!("DATABASE_URL"),
  socket_options: [keepalive: true],
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 20,
  timeout: 240_000
