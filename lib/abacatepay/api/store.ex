defmodule AbacatePay.Api.Store do
  @moduledoc ~S"""
  Module for handling store-related endpoints in the API.
  """

  @doc """
  Allows you to retrieve the details of your account/store, including balance information.

  ## Examples

      iex> AbacatePay.Api.Store.get_store()
      {:ok, %{...}}
  """
  def get_store do
    AbacatePay.HTTPClient.get("/store/get")
  end
end
