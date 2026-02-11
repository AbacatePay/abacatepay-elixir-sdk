defmodule AbacatePay.Api.Customer do
  @moduledoc ~S"""
  Module for handling customer-related endpoints in the API.
  """

  alias AbacatePay.{HTTPClient, ApiError}

  @doc """
  Creates a new customer.

  ## Examples

      iex> AbacatePay.Api.Customer.create(%{name: "Daniel Lima", cellphone: "(11) 4002-8922", email: "daniel.lima@example.com", taxId: "123.456.789-01"})
      {:ok, %{...}}
  """
  @spec create(body :: map()) :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def create(body) do
    HTTPClient.post(
      "/customers/create",
      body
    )
  end

  @doc """
  Lists customers.

  ## Examples

      iex> AbacatePay.Api.Customer.list(%{page: 1, limit: 20})
      {:ok, [%{...}, ...]}
  """
  @spec list(params :: map()) :: {:ok, list(), map()} | {:error, ApiError.t()} | {:error, any()}
  def list(params \\ %{page: 1, limit: 20}) do
    query = URI.encode_query(%{"page" => params.page, "limit" => params.limit})

    HTTPClient.get("/customers/list?" <> query)
  end

  @doc """
  Gets a customer by ID.

  ## Examples

      iex> AbacatePay.Api.Customer.get("cust_aebxkhDZNaMmJeKsy0AHS0FQ")
      {:ok, %{...}}
  """
  @spec get(customer_id :: String.t()) :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def get(customer_id) do
    query = URI.encode_query(%{"id" => customer_id})

    HTTPClient.get("/customers/get?" <> query)
  end
end
