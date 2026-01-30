defmodule AbacatePay.Api.Coupon do
  @moduledoc ~S"""
  Module for handling coupon-related endpoints in the API.
  """

  def create_coupon(body) do
    AbacatePay.HTTPClient.post("/coupon/create", body)
  end

  @doc """
  Gets a list of all coupons.

  ## Examples

      iex> AbacatePay.Api.Coupon.list_coupons()
      {:ok, [%{...}, ...]}
  """
  def list_coupons do
    AbacatePay.HTTPClient.get("/coupon/list")
  end
end
