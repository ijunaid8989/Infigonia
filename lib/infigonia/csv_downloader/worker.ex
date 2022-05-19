defmodule Infigonia.CSVDownloader.Worker do
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

  def handle_continue(:download_csv, state) do
    %{sources: sources} = state

    stream_csvs(sources)
    Logger.info("Fetching the CSV from source.")

    clock = Process.send_after(self(), :download_csv, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end

  def handle_info(:download_csv, state) do
    %{sources: sources} = state
    stream_csvs(sources)
    Logger.info("Fetching the CSV from source.")

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
