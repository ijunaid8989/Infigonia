defmodule Infigonia.CSVParser.Worker do
  use Oban.Worker, unique: [fields: [:args, :worker], keys: [:path]]

  @moduledoc """
  Module: CSVParser.Worker
  """

  require Logger

  alias NimbleCSV.RFC4180, as: CSV

  alias Infigonia.{UsdConversionRates, Revenues}

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(%Oban.Job{args: %{"path" => path}} = _args) do
    parse_and_save(path)
    :ok
  end

  defp parse_and_save(path) do
    parse_csv(path)
    |> prepare_for_db()
    |> Revenues.insert()

    File.rm(path)
    :ok
  end

  @spec parse_csv(String.t()) :: list(map())
  defp parse_csv(path) do
    path
    |> File.stream!([:trim_bom])
    |> CSV.parse_stream(skip_headers: false)
    |> Stream.transform([], fn
      r, [] ->
        {[], r}

      r, acc ->
        {result, others} =
          acc
          |> Enum.zip(r)
          |> Map.new()
          |> Map.split(~w|revenue currency date|)

        {[Map.put(result, "others", others)], acc}
    end)
    |> Enum.to_list()
  end

  @spec prepare_for_db(list(map())) :: list(map())
  defp prepare_for_db(data_from_csv) do
    rates = UsdConversionRates.latest_usd_rates().rates

    data_from_csv
    |> Enum.map(fn data ->
      currency = String.to_atom(data["currency"])
      revenue = String.to_float(data["revenue"])

      rate = get_rate(rates, currency)

      %{
        currency: data["currency"],
        date: Date.from_iso8601!(data["date"]),
        others: data["others"],
        revenue: revenue * rate
      }
    end)
  end

  defp get_rate(rates, currency) do
    case Map.fetch(rates, currency) do
      {:ok, rate} -> rate
      _error -> 0
    end
  end
end
