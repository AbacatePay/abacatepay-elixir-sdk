defmodule AbacatePay.Api.Coupon do
  @moduledoc ~S"""
  Module for handling coupon-related endpoints in the API.
  """

  alias AbacatePay.{HTTPClient, ApiError}

  @doc """
  Creates a new coupon.

  ## Examples

      iex> AbacatePay.Api.Coupon.create_coupon(%{code: "DEYVIN_20", discountKind: "PERCENTAGE", discount: 15})
      {:ok, %{...}}
  """
  @spec create_coupon(body :: map()) :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def create_coupon(body) do
    HTTPClient.post("/coupon/create", body)
  end

  @doc """
  Gets a list of all coupons.

  ## Examples

      iex> AbacatePay.Api.Coupon.list_coupons()
      {:ok, [%{...}, ...]}
  """
  @spec list_coupons() :: {:ok, list(map())} | {:error, ApiError.t()} | {:error, any()}
  def list_coupons do
    HTTPClient.get("/coupon/list")
  end
end
