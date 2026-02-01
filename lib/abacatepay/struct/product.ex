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

  @typedoc "The product id on your system. We use this id to create your product on AbacatePay automatically, so make sure your id is unique."
  @type external_id :: String.t()

  @typedoc "Quantity of product being purchased."
  @type quantity :: non_neg_integer()

  @typedoc "Price per unit of product in cents. The minimum is 100 (1 BRL)."
  @type price :: non_neg_integer()

  @typedoc "Detailed product description."
  @type description :: String.t() | nil

  @typedoc "Product name."
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
      external_id: raw_data["externalId"],
      quantity: raw_data["quantity"],
      price: raw_data["price"],
      description: raw_data["description"],
      name: raw_data["name"]
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
