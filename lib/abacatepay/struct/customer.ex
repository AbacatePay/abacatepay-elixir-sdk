defmodule AbacatePay.Customer do
  @moduledoc ~S"""
  Module that represents a customer in AbacatePay.
  """

  alias AbacatePay.{Api, Schema}

  defstruct [
    :id,
    :name,
    :cellphone,
    :tax_id,
    :email
  ]

  @typedoc "The customer unique ID in AbacatePay."
  @type id :: String.t()

  @typedoc "The customer name."
  @type name :: String.t() | nil

  @typedoc "The customer cellphone."
  @type cellphone :: String.t() | nil

  @typedoc "The customer tax ID (CPF or CNPJ)."
  @type tax_id :: String.t() | nil

  @typedoc "The customer email."
  @type email :: String.t()

  @type t :: %__MODULE__{
          id: id,
          name: name,
          cellphone: cellphone,
          tax_id: tax_id,
          email: email
        }

  @doc """
  Creates a new customer.

  ## Examples
      iex> AbacatePay.Customer.create([
        name: "Daniel Lima",
        cellphone: "(11) 4002-8922",
        email: "daniel_lima@abacatepay.com",
        tax_id: "123.456.789-01"
      ])
      {:ok, %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", ...}}

  Options: \n#{NimbleOptions.docs(Schema.Customer.create_customer_request())}
  """
  @spec create(options :: keyword()) :: {:ok, t()} | {:error, any()}
  def create(options) do
    case NimbleOptions.validate(options, Schema.Customer.create_customer_request()) do
      {:ok, validated_options} ->
        body =
          %{
            name: validated_options[:name],
            cellphone: validated_options[:cellphone],
            email: validated_options[:email],
            taxId: validated_options[:tax_id]
          }
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Enum.into(%{})

        with {:ok, response} <- Api.Customer.create_customer(body) do
          build_pretty_customer(response)
        end

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, error}
    end
  end

  @doc """
  Gets a list of all customers.

  ## Examples
      iex> AbacatePay.Customer.list()
      {:ok, [%AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...}, ...]}
  """
  @spec list() :: {:ok, [t()]} | {:error, any()}
  def list do
    with {:ok, data_list} <- Api.Customer.list_customers() do
      pretty_customers =
        data_list
        |> Enum.map(&build_pretty_customer/1)
        |> Enum.map(fn {:ok, customer} -> customer end)

      {:ok, pretty_customers}
    end
  end

  @doc """
  Builds a `AbacatePay.Customer` struct from raw API data.

  ## Examples
      iex> raw_data = %{
      ...>   "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   "metadata" => %{
      ...>     "name" => "Daniel Lima",
      ...>     "cellphone" => "(11) 4002-8922",
      ...>     "email" => "daniel_lima@abacatepay.com",
      ...>     "taxId" => "123.456.789-01"
      ...>   }
      ...> }
      iex> AbacatePay.Customer.build_pretty_customer(raw_data)
      {:ok, %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", ...}}
  """
  @spec build_pretty_customer(raw_data :: map()) :: {:ok, t()}
  def build_pretty_customer(raw_data) do
    pretty_fields = %AbacatePay.Customer{
      id: raw_data["id"],
      name: get_in(raw_data, ["metadata", "name"]),
      cellphone: get_in(raw_data, ["metadata", "cellphone"]),
      tax_id: get_in(raw_data, ["metadata", "taxId"]),
      email: get_in(raw_data, ["metadata", "email"])
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Customer` struct.

  ## Examples
      iex> customer = %AbacatePay.Customer{
      ...>   id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   name: "Daniel Lima",
      ...>   cellphone: "(11) 4002-8922",
      ...>   email: "daniel_lima@abacatepay.com",
      ...>   tax_id: "123.456.789-01"
      ...> }
      iex> AbacatePay.Customer.build_api_customer(customer)
      {:ok, %{
        id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        metadata: %{
          name: "Daniel Lima",
          cellphone: "(11) 4002-8922",
          taxId: "123.456.789-01",
          email: "daniel_lima@abacatepay.com"
        }
      }}
  """
  @spec build_api_customer(pretty_customer :: t()) :: {:ok, map()}
  def build_api_customer(pretty_customer) do
    api_fields = %{
      id: pretty_customer.id,
      metadata: %{
        name: pretty_customer.name,
        cellphone: pretty_customer.cellphone,
        taxId: pretty_customer.tax_id,
        email: pretty_customer.email
      }
    }

    {:ok, api_fields}
  end
end
