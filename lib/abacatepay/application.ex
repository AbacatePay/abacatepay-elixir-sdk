defmodule AbacatePay.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Finch HTTP client
      {Finch, name: AbacatePay.Finch}
    ]

    opts = [strategy: :one_for_one, name: AbacatePay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
