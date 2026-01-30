defmodule Abacatepay.Billing do
  @moduledoc """
  Handles billing-related operations with the Abacatepay API.

  ## Examples

      client = Abacatepay.Client.new("your_api_key")
      
      # Create a billing
      billing_data = %{
        frequency: :ONE_TIME,
        methods: [:PIX],
        products: [
          %{
            externalId: "prod_123",
            name: "Product 1",
            quantity: 1,
            price: 100.0
          }
        ],
        returnUrl: "https://your-site.com/return",
        completionUrl: "https://your-site.com/complete"
      }

      { :ok, billing } = Abacatepay.Billing.create(client, billing_data)
  """

  alias Abacatepay.Client
  alias Abacatepay.Types.Billing

  @doc """
  Create a new billing
  """
  @spec create(Client.t(), Billing.create_data()) :: Billing.response()
  def create(client, params) do
    case Client.post(client, "/billing/create", Jason.encode!(params)) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, struct(Billing, body)}

      {:ok, %{status_code: _, body: %{"error" => error}}} ->
        {:error, error}

      {:error, error} ->
        {:error, error.reason}
    end
  end

  @doc """
  List Billings
  """
  @spec list(Client.t()) :: Billing.list_response()
  def list(client) do
    case Client.get(client, "/billing/list") do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Enum.map(body["billings"], &struct(Billing, &1))}

      {:ok, %{status_code: _, body: %{"error" => error}}} ->
        {:error, error}

      {:error, error} ->
        {:error, error.reason}
    end
  end
end
