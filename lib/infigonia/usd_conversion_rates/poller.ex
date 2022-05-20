defmodule Infigonia.UsdConversionRates.Poller do
  @moduledoc """
  Module: Poller
  This is responsible for fetching latest currency rates with respect to USD, as base currency, we are using, Exchangerate API. The worker
  will run after each day, and fetch records, on DataBase Level have added a unique index over datetime so, even if the rates where fetched already
  for a day, and application got crashed or restarted, it won't duplicate, we are doing nothing on unique index conflict.
  """

  use GenServer

  alias Infigonia.{API.Exchangerates, UsdConversionRates}

  require Logger

  # a day
  @runner 86400

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opt) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec init(map()) :: {:ok, any, {:continue, :fetch_rates}}
  def init(state) do
    {:ok, state, {:continue, :fetch_rates}}
  end

  @spec handle_continue(:fetch_rates, map) ::
          {:noreply, %{:clock => reference, optional(any) => any}}
  def handle_continue(:fetch_rates, state) do
    Exchangerates.latest()
    |> UsdConversionRates.insert()

    Logger.info("Fetching the rates and setting the clock")

    clock = Process.send_after(self(), :fetch_rates, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end

  def handle_info(:fetch_rates, state) do
    Exchangerates.latest()
    |> UsdConversionRates.insert()

    Logger.info("Fetching the rates and setting the clock from ticker")

    clock = Process.send_after(self(), :fetch_rates, @runner)

    {:noreply, Map.put(state, :clock, clock)}
  end
end
