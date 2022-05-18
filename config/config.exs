import Config

config :infigonia,
  ecto_repos: [Infigonia.Repo]

import_config "#{config_env()}.exs"
