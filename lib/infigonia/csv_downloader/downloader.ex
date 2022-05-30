defmodule Infigonia.CSVDownloader.Downloader do
  use Oban.Worker, queue: :hardworker

  alias Infigonia.Sources.Source
  alias Infigonia.CSVDownloader.Worker

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(%Oban.Job{} = _job) do
    Source.sources()
    |> Task.async_stream(
      fn source ->
        %{source: source.url}
        |> Worker.new()
        |> Oban.insert()
      end,
      max_concurrency: 10,
      timeout: :infinity
    )
    |> Stream.run()

    :ok
  end
end
