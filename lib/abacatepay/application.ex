defmodule AbacatePay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  @moduledoc false

  alias AbacatePay.Config

  use Application

  @impl true
  def start(_type, _args) do
    config = Config.validate!()
    :ok = Config.persist(config)

    children = [
      # Start the Finch HTTP client
      {Finch, name: AbacatePay.Finch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AbacatePay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
