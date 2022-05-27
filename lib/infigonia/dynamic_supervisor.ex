defmodule Infigonia.DynamicSupervisor do
  @moduledoc """
  DynamicSupervisor:

  We are using DynamicSupervisor for starting each our Worker as a child, with one for one strategy.

  So each worker can run independently from each other and, if one would crashed, others will continue work and the crashed one
  will start it self again.
  """
  use DynamicSupervisor

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl DynamicSupervisor
  @spec init(any) ::
          {:ok,
           %{
             extra_arguments: list,
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(opts) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [opts])
  end

  @spec start_children :: :ok
  def start_children do
    start_child(Infigonia.UsdConversionRates.Poller, %{})
    # source would a string urls, something like https://localhost:4000/itsacsv.csv
    start_child(Infigonia.CSVDownloader.Worker, %{sources: []})
    start_child(Infigonia.CSVParser.Worker, %{})

    :ok
  end

  @spec start_child(atom, map()) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_child(module, opts) do
    DynamicSupervisor.start_child(__MODULE__, {module, opts})
  end
end
