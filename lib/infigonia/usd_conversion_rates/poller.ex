defmodule Infigonia.UsdConversionRates.Poller do
  use Oban.Worker, queue: :periodic, max_attempts: 3

  @moduledoc """
  Module: Poller
  This is responsible for fetching latest currency rates with respect to USD, as base currency, we are using, Exchangerate API. The worker
  will run after each day, and fetch records, on DataBase Level have added a unique index over datetime so, even if the rates where fetched already
  for a day, and application got crashed or restarted, it won't duplicate, we are doing nothing on unique index conflict.

  UPDATE: I have moved this part to be an Oban Worker instead. Oban has this builtin feature to carry node cluster structure. Collection of USD rates
  would only run one single node, if more than one node is running then only one would be responsible for fetching the rates.

  ## Example

  iex --sname foo -S mix
  iex(foo@ijunaid8989)1>

  iex --sname boo -S mix
  iex(boo@ijunaid8989)1>

  now the leader node would be the one to fetch USD rates, if the leader node would die, the 2nd node would be responsible for starting the worker.
  """
  alias Infigonia.{API.Exchangerates, UsdConversionRates}

  require Logger

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(%Oban.Job{} = _job) do
    Logger.info("Fetching UsdConversionRates.")

    Exchangerates.latest()
    |> UsdConversionRates.insert()

    :ok
  end
end
