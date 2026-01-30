defmodule AbacatePay.Api.Customer do
  @moduledoc ~S"""
  Module for handling customer-related endpoints in the API.
  """

  @doc """
  Creates a new customer.

  ## Examples

      iex> AbacatePay.Api.Customer.create_customer(%{name: "Daniel Lima", cellphone: "(11) 4002-8922", email: "daniel.lima@example.com", taxId: "123.456.789-01"})
      {:ok, %{...}}
  """
  @spec create_customer(body :: map()) :: {:ok, map()} | {:error, any()}
  def create_customer(body) do
    AbacatePay.HTTPClient.post(
      "/customers/create",
      body
    )
  end

  @doc """
  Gets a list of all customers.

  ## Examples

      iex> AbacatePay.Api.Customer.list_customers()
      {:ok, [%{...}, ...]}
  """
  @spec list_customers() :: {:ok, list(map())} | {:error, any()}
  def list_customers do
    AbacatePay.HTTPClient.get("/customers/list")
  end
end
