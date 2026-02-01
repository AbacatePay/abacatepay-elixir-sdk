defmodule AbacatePay.Api.Withdraw do
  @moduledoc ~S"""
  Module for handling Withdraw-related endpoints in the API.
  """

  @doc """
  Creates a new withdraw.

  ## Examples

      iex> AbacatePay.Api.Withdraw.create_withdraw(%{amount: 5000, externalId: "withdraw_12345"})
      {:ok, %{...}}
  """
  @spec create_withdraw(body :: map()) :: {:ok, map()} | {:error, AbacatePay.ApiError.t()}
  def create_withdraw(body) do
    AbacatePay.HTTPClient.post(
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
          {:ok, map()} | {:error, AbacatePay.ApiError.t()}
  def get_withdraw(external_id) do
    AbacatePay.HTTPClient.get("/withdraw/get/?externalId=#{external_id}")
  end

  @doc """
  Lists all withdraws.

  ## Examples

      iex> AbacatePay.Api.Withdraw.list_withdraws()
      {:ok, [%{...}, %{...}]}
  """
  @spec list_withdraws() :: {:ok, list(map())} | {:error, AbacatePay.ApiError.t()}
  def list_withdraws do
    AbacatePay.HTTPClient.get("/withdraw/list")
  end
end
