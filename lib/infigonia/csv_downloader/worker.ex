defmodule Infigonia.CSVDownloader.Worker do
  @moduledoc """
  Module: CSVDownloader.Worker
  The purpose of the module is to download CSV files from the sources and save them to downloaded folder.

  the source at initial stage is a list, so this worker would start with a map i.e %{sources: ["source_url"]}.

  You can also update the sources,

  ## Example
  iex> Infigonia.CSVDownloader.Worker.start_link(%{sources: ["https://testsoruce.com/test.csv"]})
  {:ok, pid}

  Infigonia.CSVDownloader.Worker.add_a_new_source("https://new_source_url.com/test.csv")

  :ok

  every 6 hours, it would fetch CSVs from the source and save them.
  iex>
  """
  use GenServer

  require Logger

  alias NimbleCSV.RFC4180, as: CSV

  @path "csvs/downloaded/"

  # 6 hours
  @runner 21_600_000

  @utf_encodings :unicode.encoding_to_bom(:utf8)

  @spec start_link(map()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @spec init(map()) :: {:ok, any, {:continue, :download_csv}}
  def init(state) do
    {:ok, state, {:continue, :download_csv}}
  end

  @spec handle_continue(:download_csv, %{:sources => list(String.t()), :clock => reference}) ::
          {:noreply, %{:clock => reference, :sources => any}}
  def handle_continue(:download_csv, %{sources: sources} = state) do
    stream_csvs(sources)
    Logger.info("Fetching the CSV from source.")

    clock = Process.send_after(self(), :download_csv, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end

  def handle_info(:download_csv, %{sources: sources} = state) do
    stream_csvs(sources)

    Logger.info("Fetching the CSV from source and setting the clock from ticker")

    clock = Process.send_after(self(), :download_csv, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end

  def handle_cast({:push, source}, %{sources: sources} = state) do
    {:noreply, Map.put(state, :sources, [source | sources])}
  end

  @spec add_a_new_source(String.t()) :: :ok
  def add_a_new_source(source) do
    GenServer.cast(__MODULE__, {:push, source})
  end

  defp download(source) do
    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <- HTTPoison.get(source),
         csv_data <- CSV.parse_string(body, skip_headers: false) do
      tocsv(csv_data)
    else
      _error ->
        []
    end
  end

  defp tocsv(csv_data) do
    io_data =
      csv_data
      |> CSV.dump_to_iodata()

    File.write!(@path <> Ecto.UUID.generate() <> ".csv", [@utf_encodings, io_data])
    :ok
  end

  defp stream_csvs(sources) do
    downloader = fn source ->
      download(source)
    end

    sources
    |> Task.async_stream(downloader, max_concurrency: 10, timeout: :infinity)
    |> Stream.run()
  end
end
