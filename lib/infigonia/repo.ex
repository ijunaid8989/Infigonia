defmodule Infigonia.Repo do
  use Ecto.Repo,
    otp_app: :infigonia,
    adapter: Ecto.Adapters.Postgres
end
