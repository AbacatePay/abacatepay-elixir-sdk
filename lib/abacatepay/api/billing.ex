defmodule AbacatePay.Api.Billing do
  @moduledoc ~S"""
  Module for handling billing-related endpoints in the API.
  """

  alias AbacatePay.{HTTPClient, ApiError}

  @doc """
  Creates a new billing.

  ## Examples

      iex> AbacatePay.Api.Billing.create_billing(%{...})
      {:ok, %{...}}
  """
  @spec create_billing(body :: map()) ::
          {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def create_billing(body) do
    HTTPClient.post(
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
  @spec list_billings() :: {:ok, list(map())} | {:error, ApiError.t()} | {:error, any()}
  def list_billings do
    HTTPClient.get("/billing/list")
  end
end
