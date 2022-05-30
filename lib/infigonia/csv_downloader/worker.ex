defmodule Infigonia.CSVDownloader.Worker do
  use Oban.Worker, unique: [fields: [:args, :worker], keys: [:source]]

  require Logger

  alias NimbleCSV.RFC4180, as: CSV

  @path "csvs/downloaded/"

  @utf_encodings :unicode.encoding_to_bom(:utf8)

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(%Oban.Job{args: %{"source" => source}} = _args) do
    download(source)
    :ok
  end

  defp download(source) do
    Logger.info("Downloading CSV from Source #{source}")

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
end
