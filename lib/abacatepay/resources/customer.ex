defmodule Abacatepay.Customer do
  @moduledoc """
  Handles customer-related operations with the Abacatepay API.

  ## Examples

      client = Abacatepay.Client.new("your_api_key")
      
      # Create a customer
      customer_data = %{
        name: "John Doe",
        taxId: "123.456.789-00", 
        email: "john@example.com",
        cellphone: "+5511999999999"
      }

      { :ok, customer } = Abacatepay.Customer.create(client, customer_data)
  """

  alias Abacatepay.Client
  alias Abacatepay.Types.Customer

  @doc """
  Create a new customer
  """
  @spec create(Client.t(), Customer.metadata()) :: Customer.response()
  def create(client, params) do
    case Client.post(client, "/customer/create", Jason.encode!(params)) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, struct(Customer, body)}

      {:ok, %{status_code: _, body: %{"error" => error}}} ->
        {:error, error}

      {:error, error} ->
        {:error, error.reason}
    end
  end

  @doc """
  List Customers
  """
  @spec list(Client.t()) :: Customer.list_response()
  def list(client) do
    case Client.get(client, "/customer/list") do
      {:ok, %{status_code: 200, body: %{"data" => data}}} ->
        {:ok, Enum.map(data, &struct(Customer, &1))}

      {:ok, %{status_code: _, body: %{"error" => error}}} ->
        {:error, error}

      {:error, error} ->
        {:error, error.reason}
    end
  end
end
