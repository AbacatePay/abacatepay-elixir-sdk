defmodule AbacatePay.Api.Billing do
  @moduledoc ~S"""
  Module for handling /billing endpoints in the API.
  """

  @doc """
  Creates a new billing.

  ## Examples

      iex> AbacatePay.HTTPClient.Billing.create_billing(%{...})
      {:ok, %{...}}
  """
  def create_billing(body) do
    AbacatePay.HTTPClient.post(
      "/billing/create",
      body
    )
  end

  @doc """
  Gets a list of all billings.

  ## Examples

      iex> AbacatePay.HTTPClient.Billing.list_billings()
      {:ok, [%{...}, ...]}
  """
  def list_billings do
    AbacatePay.HTTPClient.get("/billing/list")
  end
end
