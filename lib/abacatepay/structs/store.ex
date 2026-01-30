defmodule AbacatePay.Store do
  @moduledoc ~S"""
  Module that represents a store in AbacatePay.
  """

  alias AbacatePay.Api

  defstruct [
    :id,
    :name,
    :balance
  ]

  @typedoc "The store unique ID in AbacatePay."
  @type id :: String.t()

  @typedoc "The store name."
  @type name :: String.t()

  @typedoc """
  Object containing information about your account balances.

  - `:available` - Available balance for withdrawal in cents.
  - `:pending` - Pending balance awaiting confirmation in cents.
  - `:blocked` - Balance blocked in disputes in cents.
  """
  @type balance :: %{
          available: non_neg_integer(),
          pending: non_neg_integer(),
          blocked: non_neg_integer()
        }

  @type t :: %__MODULE__{
          id: id,
          name: name,
          balance: balance
        }

  @doc """
  Allows you to retrieve the details of your account/store, including balance information.

  ## Examples

      iex> AbacatePay.Store.get()
      {:ok, %AbacatePay.Store{id: "store_ABC123", name: "My Store", balance: %{available: 100000, pending: 5000, blocked: 2000}}}
  """
  @spec get() :: {:ok, t()} | {:error, any()}
  def get do
    case Api.Store.get_store() do
      {:ok, data} ->
        build_pretty_store(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Builds a `AbacatePay.Store` struct from raw API data.

  ## Examples

      iex> raw_data = %{
      ...>   "id" => "store_ABC123",
      ...>   "name" => "My Store",
      ...>   "balance" => %{
      ...>     "available" => 100000,
      ...>     "pending" => 5000,
      ...>     "blocked" => 2000
      ...>   }
      ...> }
      iex> AbacatePay.Store.build_pretty_store(raw_data)
      {:ok, %AbacatePay.Store{
        id: "store_ABC123",
        name: "My Store",
        balance: %{
          available: 100000,
          pending: 5000,
          blocked: 2000
        }
      }}
  """
  @spec build_pretty_store(raw_data :: map()) :: {:ok, t()}
  def build_pretty_store(raw_data) do
    pretty_fields = %AbacatePay.Store{
      id: Map.get(raw_data, "id"),
      name: Map.get(raw_data, "name"),
      balance: %{
        available: get_in(raw_data, ["balance", "available"]),
        pending: get_in(raw_data, ["balance", "pending"]),
        blocked: get_in(raw_data, ["balance", "blocked"])
      }
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Store` struct.

  ## Examples

      iex> store = %AbacatePay.Store{
      ...>   id: "store_ABC123",
      ...>   name: "My Store",
      ...>   balance: %{
      ...>     available: 100000,
      ...>     pending: 5000,
      ...>     blocked: 2000
      ...>   }
      ...> }
      iex> AbacatePay.Store.build_api_store(store)
      {:ok, %{
        id: "store_ABC123",
        name: "My Store",
        balance: %{
          available: 100000,
          pending: 5000,
          blocked: 2000
        }
      }}
  """
  @spec build_api_store(pretty_store :: t()) :: {:ok, map()}
  def build_api_store(pretty_store) do
    api_fields = %{
      id: pretty_store.id,
      name: pretty_store.name,
      balance: %{
        available: pretty_store.balance.available,
        pending: pretty_store.balance.pending,
        blocked: pretty_store.balance.blocked
      }
    }

    {:ok, api_fields}
  end
end
