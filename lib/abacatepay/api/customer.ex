defmodule AbacatePay.Api.Customer do
  @moduledoc ~S"""
  Module for handling /customer endpoints in the API.
  """

  @doc """
  Creates a new customer.

  ## Examples

      iex> AbacatePay.HTTPClient.Customer.create_customer(%{name: "Daniel Lima", cellphone: "(11) 4002-8922", email: "daniel.lima@example.com"})
      {:ok, %{...}}
  """
  def create_customer(body) do
    AbacatePay.HTTPClient.post(
      "/customers/create",
      body
    )
  end

  @doc """
  Gets a list of all customers.

  ## Examples

      iex> AbacatePay.HTTPClient.Customer.list_customers()
      {:ok, [%{...}, ...]}
  """
  def list_customers do
    AbacatePay.HTTPClient.get("/customers/list")
  end
end
