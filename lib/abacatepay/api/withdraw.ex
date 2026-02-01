defmodule AbacatePay.Api.Withdraw do
  @moduledoc ~S"""
  Module for handling Withdraw-related endpoints in the API.
  """

  alias AbacatePay.{HTTPClient, ApiError}

  @doc """
  Creates a new withdraw.

  ## Examples

      iex> AbacatePay.Api.Withdraw.create_withdraw(%{amount: 5000, externalId: "withdraw_12345"})
      {:ok, %{...}}
  """
  @spec create_withdraw(body :: map()) :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def create_withdraw(body) do
    HTTPClient.post(
      "/withdraw/create",
      body
    )
  end

  @doc """
  Gets a withdraw by its external ID.

  ## Examples

      iex> AbacatePay.Api.Withdraw.get_withdraw("withdraw_12345")
      {:ok, %{...}}
  """
  @spec get_withdraw(external_id :: String.t()) ::
          {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def get_withdraw(external_id) do
    query = URI.encode_query(%{"externalId" => external_id})

    HTTPClient.get("/withdraw/get?" <> query)
  end

  @doc """
  Lists all withdraws.

  ## Examples

      iex> AbacatePay.Api.Withdraw.list_withdraws()
      {:ok, [%{...}, %{...}]}
  """
  @spec list_withdraws() :: {:ok, list(map())} | {:error, ApiError.t()} | {:error, any()}
  def list_withdraws do
    HTTPClient.get("/withdraw/list")
  end
end
