defmodule Infigonia.UsdConversionRates do
  use Ecto.Schema

  alias Infigonia.Repo

  import Ecto.{Changeset, Query}

  schema "usd_conversion_rates" do
    field(:datetime, :utc_datetime)
    embeds_one(:rates, Infigonia.CurrencyRates)
  end

  def insert(rates_and_time) do
    %Infigonia.UsdConversionRates{}
    |> changeset(rates_and_time)
    |> Repo.insert(on_conflict: :nothing)
  end

  def latest_usd_rates() do
    Infigonia.UsdConversionRates
    |> last(:datetime)
    |> Repo.one()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:datetime])
    |> cast_embed(:rates, required: true)
    |> validate_required([:datetime])
  end
end
