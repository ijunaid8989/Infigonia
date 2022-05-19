defmodule Infigonia.UsdConversionRates.Poller do
  use GenServer

  alias Infigonia.{API.Exchangerates, UsdConversionRates}

  require Logger

  def start_link(_args) do
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

    clock = Process.send_after(self(), :fetch_rates, 10_000)

    {:noreply, Map.put(state, :clock, clock)}
  end

  def handle_info(:fetch_rates, state) do
    Exchangerates.latest()
    |> UsdConversionRates.insert()

    Logger.info("Fetching the rates and setting the clock from ticker")

    clock = Process.send_after(self(), :fetch_rates, 10_000)

    {:noreply, Map.put(state, :clock, clock)}
  end
end
