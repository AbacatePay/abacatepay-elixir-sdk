defmodule AbacatePay.Api.Billing do
  @moduledoc ~S"""
  Module for handling billing-related endpoints in the API.
  """

  @doc """
  Creates a new billing.

  ## Examples

      iex> AbacatePay.Api.Billing.create_billing(%{...})
      {:ok, %{...}}
  """
  @spec create_billing(body :: map()) :: {:ok, map()} | {:error, any()}
  def create_billing(body) do
    AbacatePay.HTTPClient.post(
      "/billing/create",
      body
    )
  end

  @doc """
  Gets a list of all billings.

  ## Examples

      iex> AbacatePay.Api.Billing.list_billings()
      {:ok, [%{...}, ...]}
  """
  @spec list_billings() :: {:ok, list(map())} | {:error, any()}
  def list_billings do
    AbacatePay.HTTPClient.get("/billing/list")
  end
end
