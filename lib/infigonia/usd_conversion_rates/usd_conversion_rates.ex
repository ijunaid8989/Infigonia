defmodule Infigonia.UsdConversionRates do
  use Ecto.Schema

  schema "usd_conversion_rates" do
    field(:datetime, :utc_datetime)
    embeds_many :rates, Infigonia.CurrencyRates
  end
end
