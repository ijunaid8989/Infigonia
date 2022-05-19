defmodule Infigonia.Repo.Migrations.UsdConversionRates do
  use Ecto.Migration

  def change do
    create table("usd_conversion_rates") do
      add :datetime, :utc_datetime
      add :rates, :map, default: %{}
    end

    # create index("usd_conversion_rates", ["(datetime::date)"])
    create unique_index("usd_conversion_rates", ["(datetime::date)"])
  end
end
