defmodule Infigonia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Infigonia.Repo,
      {Oban, oban_opts()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Infigonia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Please see the documentation for Oban, to spread queues on nodes. https://hexdocs.pm/oban/splitting-queues.html
  defp oban_opts do
    env_queues = System.get_env("OBAN_QUEUES")

    :infigonia
    |> Application.get_env(Oban)
    |> Keyword.update(:queues, [], &queues(env_queues, &1))
  end

  defp queues("*", defaults), do: defaults
  defp queues(nil, defaults), do: defaults
  defp queues(_, false), do: false

  defp queues(values, _defaults) when is_binary(values) do
    values
    |> String.split(" ", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Keyword.new(fn [queue, limit] ->
      {String.to_existing_atom(queue), String.to_integer(limit)}
    end)
  end
end
