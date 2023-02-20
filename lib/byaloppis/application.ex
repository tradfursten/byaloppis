defmodule Byaloppis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ByaloppisWeb.Telemetry,
      # Start the Ecto repository
      Byaloppis.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Byaloppis.PubSub},
      # Start Finch
      {Finch, name: Byaloppis.Finch},
      # Start the Endpoint (http/https)
      ByaloppisWeb.Endpoint
      # Start a worker by calling: Byaloppis.Worker.start_link(arg)
      # {Byaloppis.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Byaloppis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ByaloppisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
