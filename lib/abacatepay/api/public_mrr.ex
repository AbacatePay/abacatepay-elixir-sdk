defmodule AbacatePay.Api.PublicMRR do
  @moduledoc ~S"""
  Module for handling Public MRR-related endpoints in the API.
  """

  alias AbacatePay.{HTTPClient, ApiError}

  @doc """
  Retrieves the public Monthly Recurring Revenue (MRR) and the total number of active subscriptions in the store.

  ## Examples

      iex> AbacatePay.Api.PublicMRR.get_mrr()
      {:ok, %{"mrr": 0, "totalActiveSubscriptions": 0}}
  """
  @spec get_mrr() :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def get_mrr do
    HTTPClient.get("/public-mrr/mrr")
  end

  @doc """
  Return basic store information (name, website, and creation details).

  ## Examples

      iex> AbacatePay.Api.PublicMRR.get_merchant_info()
      {:ok, %{"name": "Example Tech", "website": "https://www.example.com", "createdAt": "2024-12-06T18:53:31.756Z"}}
  """
  @spec get_merchant_info() :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def get_merchant_info do
    HTTPClient.get("/public-mrr/merchant-info")
  end

  @doc """
  Retrieves the revenue data for the store within a specified date range.

  ## Examples

      iex> AbacatePay.Api.PublicMRR.get_revenue("2024-01-01", "2024-01-31")
      {:ok, %{"totalRevenue": 150000, "totalTransactions": 45, "transactionsPerDay": %{...}}}
  """
  @spec get_revenue(String.t(), String.t()) ::
          {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def get_revenue(start_date, end_date) do
    query = URI.encode_query(%{"startDate" => start_date, "endDate" => end_date})

    HTTPClient.get("/public-mrr/revenue?" <> query)
  end
end
