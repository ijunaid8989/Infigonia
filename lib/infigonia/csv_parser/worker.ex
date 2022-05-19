defmodule Infigonia.CSVParser.Worker do
  use GenServer

  require Logger

  alias NimbleCSV.RFC4180, as: CSV

  alias Infigonia.{UsdConversionRates, Revenues}

  @path "csvs/downloaded/"

  # 3 hours
  @runner 10800

  @spec start_link(map()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @spec init(map()) :: {:ok, any, {:continue, :sync_db}}
  def init(state) do
    {:ok, state, {:continue, :sync_db}}
  end

  @spec handle_continue(:sync_db, map) :: {:noreply, %{:clock => reference}}
  def handle_continue(:sync_db, state) do
    Path.wildcard(@path <> "*.csv")
    |> db_streams()

    Logger.info("Parsing the CSV from source.")

    clock = Process.send_after(self(), :sync_db, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end

  def handle_info(:sync_db, state) do
    Path.wildcard(@path <> "*.csv")
    |> db_streams()

    Logger.info("Parsing the CSV from source and setting the clock from ticker")

    clock = Process.send_after(self(), :sync_db, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end

  @spec parse_csv(String.t()) :: list(map())
  def parse_csv(path) do
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
  def prepare_for_db(data_from_csv) do
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

  defp db_streams(file_paths) do
    db_transaction = fn path ->
      parse_csv(path)
      |> prepare_for_db()
      |> Revenues.insert()

      File.rm(path)
    end

    file_paths
    |> Task.async_stream(db_transaction, max_concurrency: 10, timeout: :infinity)
    |> Stream.run()

    :ok
  end
end