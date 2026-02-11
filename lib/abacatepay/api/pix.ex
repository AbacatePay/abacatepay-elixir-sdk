defmodule AbacatePay.Api.Pix do
  @moduledoc ~S"""
  Module for handling Pix QR Code-related endpoints in the API.
  """

  alias AbacatePay.{HTTPClient, ApiError}

  @doc """
  Creates a new Pix QR Code.

  ## Examples

      iex> AbacatePay.Api.Pix.create(%{amount: 1000, description: "Payment for order #1234"})
      {:ok, %{...}}
  """
  @spec create(body :: map()) ::
          {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def create(body) do
    HTTPClient.post(
      "/pixQrCode/create",
      body
    )
  end

  @doc """
  Simulates a payment for the Pix QR Code created in development mode.

  ## Examples

      iex> AbacatePay.Api.Pix.simulate_payment("pix_charabc123456789", %{})
      {:ok, %{...}}
  """
  @spec simulate_payment(id :: String.t(), body :: map()) ::
          {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def simulate_payment(id, body) do
    query = URI.encode_query(%{"id" => id})

    HTTPClient.post(
      "/pixQrCode/simulate-payment?" <> query,
      body
    )
  end

  @doc """
  Checks the status of a Pix QR Code by its ID.

  ## Examples

      iex> AbacatePay.Api.Pix.check_status("pix_charabc123456789")
      {:ok, %{status: "PENDING", expiresAt: "2026-01-01T12:00:00Z"}}
  """
  @spec check_status(id :: String.t()) :: {:ok, map()} | {:error, ApiError.t()} | {:error, any()}
  def check_status(id) do
    query = URI.encode_query(%{"id" => id})

    HTTPClient.get("/pixQrCode/check?" <> query)
  end
end
