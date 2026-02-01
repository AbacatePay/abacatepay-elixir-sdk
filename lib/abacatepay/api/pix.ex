defmodule AbacatePay.Api.Pix do
  @moduledoc ~S"""
  Module for handling Pix QR Code-related endpoints in the API.
  """

  @doc """
  Creates a new Pix QR Code.

  ## Examples

      iex> AbacatePay.Api.Pix.create_pix_qrcode(%{amount: 1000, description: "Payment for order #1234"})
      {:ok, %{...}}
  """
  @spec create_pix_qrcode(body :: map()) :: {:ok, map()} | {:error, AbacatePay.ApiError.t()}
  def create_pix_qrcode(body) do
    AbacatePay.HTTPClient.post(
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
          {:ok, map()} | {:error, AbacatePay.ApiError.t()}
  def simulate_payment(id, body) do
    AbacatePay.HTTPClient.post(
      "/pixQrCode/simulate-payment/?id=#{id}",
      body
    )
  end

  @doc """
  Checks the status of a Pix QR Code by its ID.

  ## Examples

      iex> AbacatePay.Api.Pix.check_status("pix_charabc123456789")
      {:ok, %{status: "PENDING", expiresAt: "2026-01-01T12:00:00Z"}}
  """
  @spec check_status(id :: String.t()) :: {:ok, map()} | {:error, AbacatePay.ApiError.t()}
  def check_status(id) do
    AbacatePay.HTTPClient.get("/pixQrCode/check/?id=#{id}")
  end
end
