defmodule Infigonia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Infigonia.Repo,
      # Here we are first starting our Supervisor and then the other workers as childs, this solution was suggested by Jose here
      # https://elixirforum.com/t/understanding-dynamicsupervisor-no-initial-children/14938?u=slashdotdash
      {DynamicSupervisor, strategy: :one_for_one, name: Infigonia.DynamicSupervisor},
      {Task, &Infigonia.DynamicSupervisor.start_children/0},
      {Oban, Application.fetch_env!(:infigonia, Oban)}
      # Starts a worker by calling: Infigonia.Worker.start_link(arg)
      # {Infigonia.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Infigonia.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
