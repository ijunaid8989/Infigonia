import Config

config :infigonia,
  ecto_repos: [Infigonia.Repo]

config :infigonia,
  exchangerates_api_key: "Ox1lQeV8KiH7P79hp7I9dGpDJQeUcFx3",
  exchangerates_api_url: "https://api.apilayer.com/exchangerates_data/latest"

import_config "#{config_env()}.exs"
