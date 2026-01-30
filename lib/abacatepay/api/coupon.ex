defmodule AbacatePay.Api.Coupon do
  @moduledoc ~S"""
  Module for handling coupon-related endpoints in the API.
  """

  @doc """
  Creates a new coupon.

  ## Examples

      iex> AbacatePay.Api.Coupon.create_coupon(%{code: "DEYVIN_20", discountKind: "PERCENTAGE", discount: 15})
      {:ok, %{...}}
  """
  @spec create_coupon(body :: map()) :: {:ok, map()} | {:error, any()}
  def create_coupon(body) do
    AbacatePay.HTTPClient.post("/coupon/create", body)
  end

  @doc """
  Gets a list of all coupons.

  ## Examples

      iex> AbacatePay.Api.Coupon.list_coupons()
      {:ok, [%{...}, ...]}
  """
  @spec list_coupons() :: {:ok, list(map())} | {:error, any()}
  def list_coupons do
    AbacatePay.HTTPClient.get("/coupon/list")
  end
end
