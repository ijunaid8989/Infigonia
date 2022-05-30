defmodule Infigonia.CSVParser.Parser do
  use Oban.Worker, queue: :hardworker

  alias Infigonia.CSVParser.Worker

  @path "csvs/downloaded/"

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(%Oban.Job{} = _job) do
    Path.wildcard(@path <> "*.csv")
    |> Task.async_stream(
      fn csv ->
        %{path: csv}
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
