import Config

config :infigonia, Infigonia.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "infigonia_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :infigonia, Oban, testing: :inline
