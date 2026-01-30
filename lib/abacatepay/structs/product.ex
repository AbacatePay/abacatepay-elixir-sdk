defmodule AbacatePay.Product do
  @moduledoc ~S"""
  Module that represents a product in AbacatePay.
  """

  defstruct [
    :external_id,
    :quantity,
    :price,
    :description,
    :name
  ]

  @typedoc "The product ID in your application."
  @type external_id :: String.t()

  @typedoc "The number of units of the given product (min: 1)."
  @type quantity :: non_neg_integer()

  @typedoc "The price of the product in cents (min: 100)."
  @type price :: non_neg_integer()

  @typedoc "A detailed description of the product."
  @type description :: String.t()

  @typedoc "The product name."
  @type name :: String.t()

  @type t :: %__MODULE__{
          external_id: external_id,
          quantity: quantity,
          price: price,
          description: description,
          name: name
        }

  @doc """
  Builds a `AbacatePay.Product` struct from raw API data.

  ## Examples

      iex> raw_data = %{
      ...>   "externalId" => "prod_12345",
      ...>   "quantity" => 2,
      ...>   "price" => 1500,
      ...>   "description" => "Test product description",
      ...>   "name" => "Test Product"
      ...> }
      iex> AbacatePay.Product.build_pretty_product(raw_data)
      {:ok, %AbacatePay.Product{
        external_id: "prod_12345",
        quantity: 2,
        price: 1500,
        description: "Test product description",
        name: "Test Product"
      }}
  """
  @spec build_pretty_product(raw_data :: map()) :: {:ok, t()}
  def build_pretty_product(raw_data) do
    pretty_fields = %AbacatePay.Product{
      external_id: Map.get(raw_data, "externalId"),
      quantity: Map.get(raw_data, "quantity"),
      price: Map.get(raw_data, "price"),
      description: Map.get(raw_data, "description"),
      name: Map.get(raw_data, "name")
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Product` struct.

  ## Examples

      iex> product = %AbacatePay.Product{
      ...>   external_id: "prod_12345",
      ...>   quantity: 2,
      ...>   price: 1500,
      ...>   description: "Test product description",
      ...>   name: "Test Product"
      ...> }
      iex> AbacatePay.Product.build_api_product(product)
      {:ok, %{
        externalId: "prod_12345",
        quantity: 2,
        price: 1500,
        description: "Test product description",
        name: "Test Product"
      }}
  """
  @spec build_api_product(pretty_product :: t()) :: {:ok, map()}
  def build_api_product(pretty_product) do
    api_fields = %{
      externalId: pretty_product.external_id,
      quantity: pretty_product.quantity,
      price: pretty_product.price,
      description: pretty_product.description,
      name: pretty_product.name
    }

    {:ok, api_fields}
  end
end
