defmodule AbacatePay.PublicMRR do
  @moduledoc ~S"""
  Module that represents a Public MRR in AbacatePay.
  """
  alias AbacatePay.Api

  defstruct [
    :mrr,
    :total_active_subscriptions,
    :name,
    :total_revenue,
    :total_transactions,
    :transactions_per_day,
    :website,
    :created_at
  ]

  @typedoc "Monthly recurring revenue in cents. A value of 0 indicates that there is no recurring revenue at the moment."
  @type mrr :: non_neg_integer()

  @typedoc "Total number of active subscriptions. A value of 0 indicates that there are no active subscriptions at the moment."
  @type total_active_subscriptions :: non_neg_integer()

  @typedoc "Name of the store."
  @type name :: String.t() | nil

  @typedoc "Website of the store."
  @type website :: String.t() | nil

  @typedoc "Total revenue in cents."
  @type total_revenue :: non_neg_integer()

  @typedoc "Total number of transactions."
  @type total_transactions :: non_neg_integer()

  @typedoc "Object with transactions grouped by day (key is data in the format YYYY-MM-DD)."
  @type transactions_per_day :: map()

  @typedoc "Store creation date."
  @type created_at :: DateTime.t() | nil

  @type t :: %__MODULE__{
          mrr: mrr,
          total_active_subscriptions: total_active_subscriptions,
          name: name,
          total_revenue: total_revenue,
          total_transactions: total_transactions,
          transactions_per_day: transactions_per_day,
          website: website,
          created_at: created_at
        }

  @doc """
  Retrieves the Public MRR information for the store.

  ## Examples
      iex> AbacatePay.PublicMRR.get()
      {:ok, %AbacatePay.PublicMRR{mrr: 0, total_active_subscriptions: 0}}
  """
  @spec get() :: {:ok, t()} | {:error, any()}
  def get do
    with {:ok, response} <- Api.PublicMRR.get_mrr() do
      build_pretty_public_mrr(response)
    end
  end

  @doc """
  Retrieves the merchant information for the store.

  ## Examples
      iex> AbacatePay.PublicMRR.get_merchant_info()
      {:ok, %AbacatePay.PublicMRR{name: "Example Tech", website: "https://www.example.com", created_at: ~U[2023-01-15T10:00:00Z]}}
  """
  @spec get_merchant_info() :: {:ok, t()} | {:error, any()}
  def get_merchant_info do
    with {:ok, response} <- Api.PublicMRR.get_merchant_info() do
      build_pretty_public_mrr(response)
    end
  end

  @doc """
  Retrieves the revenue data for the store within a specified date range.

  ## Examples
      iex> AbacatePay.PublicMRR.get_revenue("2024-01-01", "2024-01-31")
      {:ok, %AbacatePay.PublicMRR{total_revenue: 150000, total_transactions: 45, transactions_per_day: %{"2024-01-15" => %{amount: 5000, count: 3}, "2024-01-16" => %{amount: 3000, count: 2}}}}
  """
  def get_revenue(start_date, end_date) do
    with {:ok, response} <- Api.PublicMRR.get_revenue(start_date, end_date) do
      build_pretty_public_mrr(response)
    end
  end

  @doc """
  Builds a `AbacatePay.PublicMRR` struct from raw API data.

  ## Examples
      iex> raw_data = %{
      ...>   "mrr" => 50000,
      ...>   "totalActiveSubscriptions" => 10,
      ...>   "name" => "My Store",
      ...>   "totalRevenue" => 150000,
      ...>   "totalTransactions" => 45,
      ...>   "transactionsPerDay" => %{"2024-01-15" => %{"amount": 5000, "count": 3}, "2024-01-16" => %{"amount": 3000, "count": 2}},
      ...>   "website" => "https://mystore.com",
      ...>   "createdAt" => "2023-12-01T12:00:00Z"
      ...> }
      iex> AbacatePay.PublicMRR.build_pretty_public_mrr(raw_data)
      {:ok, %AbacatePay.PublicMRR{
        mrr: 50000,
        total_active_subscriptions: 10,
        name: "My Store",
        total_revenue: 150000,
        total_transactions: 45,
        transactions_per_day: %{"2024-01-15" => %{amount: 5000, count: 3}, "2024-01-16" => %{amount: 3000, count: 2}},
        website: "https://mystore.com",
        created_at: ~U[2023-12-01T12:00:00Z]
      }}
  """
  @spec build_pretty_public_mrr(raw_data :: map()) :: {:ok, t()}
  def build_pretty_public_mrr(raw_data) do
    transactions_per_day =
      Enum.into(raw_data["transactionsPerDay"] || %{}, %{}, fn {date, data} ->
        {date, %{amount: data["amount"], count: data["count"]}}
      end)

    # transform createdAt string to elixir datetime
    created_at =
      case raw_data["createdAt"] do
        nil -> nil
        datetime_str -> DateTime.from_iso8601(datetime_str) |> elem(1)
      end

    pretty_fields = %AbacatePay.PublicMRR{
      mrr: raw_data["mrr"],
      total_active_subscriptions: raw_data["totalActiveSubscriptions"],
      name: raw_data["name"],
      total_revenue: raw_data["totalRevenue"],
      total_transactions: raw_data["totalTransactions"],
      transactions_per_day: transactions_per_day,
      website: raw_data["website"],
      created_at: created_at
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.PublicMRR` struct.

  ## Examples
      iex> public_mrr = %AbacatePay.PublicMRR{
      ...>   mrr: 50000,
      ...>   total_active_subscriptions: 10,
      ...>   name: "My Store",
      ...>   total_revenue: 150000,
      ...>   total_transactions: 45,
      ...>   transactions_per_day: %{"2024-01-15" => %{amount: 5000, count: 3}, "2024-01-16" => %{amount: 3000, count: 2}},
      ...>   website: "https://mystore.com",
      ...>   created_at: ~U[2023-12-01T12:00:00Z]
      ...> }
      iex> AbacatePay.PublicMRR.build_api_public_mrr(public_mrr)
      {:ok, %{
        mrr: 50000,
        totalActiveSubscriptions: 10,
        name: "My Store",
        totalRevenue: 150000,
        totalTransactions: 45,
        transactionsPerDay: %{"2024-01-15" => %{"amount" => 5000, "count" => 3}, "2024-01-16" => %{"amount" => 3000, "count" => 2}},
        website: "https://mystore.com",
        createdAt: "2023-12-01T12:00:00Z"
      }}
  """
  @spec build_api_public_mrr(pretty_public_mrr :: t()) :: {:ok, map()}
  def build_api_public_mrr(pretty_public_mrr) do
    transactions_per_day =
      Enum.into(pretty_public_mrr.transactions_per_day || %{}, %{}, fn {date, data} ->
        {date, %{"amount" => data.amount, "count" => data.count}}
      end)

    created_at =
      case pretty_public_mrr.created_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    api_fields = %{
      mrr: pretty_public_mrr.mrr,
      totalActiveSubscriptions: pretty_public_mrr.total_active_subscriptions,
      name: pretty_public_mrr.name,
      totalRevenue: pretty_public_mrr.total_revenue,
      totalTransactions: pretty_public_mrr.total_transactions,
      transactionsPerDay: transactions_per_day,
      website: pretty_public_mrr.website,
      createdAt: created_at
    }

    {:ok, api_fields}
  end
end
