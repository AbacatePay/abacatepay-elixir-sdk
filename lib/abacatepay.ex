defmodule AbacatePay do
  @moduledoc """
  Main module for the AbacatePay SDK.
  """

  require Logger

  @doc ~S"""
   Updates the value of `key` in the configuration *at runtime*.

  Once the `:abacatepay` application starts, it validates and caches the value of the
  configuration options you start it with. Because of this, updating configuration
  at runtime requires this function as opposed to just changing the application
  environment.

    > #### This Function Is Slow {: .warning}
  >
  > This function updates terms in [`:persistent_term`](`:persistent_term`), which is what
  > this SDK uses to cache configuration. Updating terms in `:persistent_term` is slow
  > and can trigger full GC sweeps. We recommend only using this function in rare cases,
  > or during tests.
  """
  @doc since: "0.3.0"
  @spec put_config(atom(), term()) :: :ok
  defdelegate put_config(key, value), to: AbacatePay.Config
end
