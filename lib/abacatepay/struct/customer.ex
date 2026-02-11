defmodule AbacatePay.Customer do
  @moduledoc ~S"""
  Struct representing an AbacatePay customer.
  """

  alias AbacatePay.{Api, ApiError, Pagination, Schema}

  defstruct [
    :id,
    :dev_mode,
    :country,
    :name,
    :cellphone,
    :tax_id,
    :zip_code,
    :email,
    :metadata
  ]

  @typedoc "Unique customer identifier."
  @type id :: String.t()

  @typedoc "Indicates whether the client was created in a testing environment."
  @type dev_mode :: boolean() | nil

  @typedoc "Customer country."
  @type country :: String.t() | nil

  @typedoc "Customer's full name."
  @type name :: String.t() | nil

  @typedoc "Customer's cell phone."
  @type cellphone :: String.t() | nil

  @typedoc "Customer's CPF or CNPJ."
  @type tax_id :: String.t() | nil

  @typedoc "Customer's email."
  @type email :: String.t()

  @typedoc "Customer zip code."
  @type zip_code :: String.t() | nil

  @typedoc "Additional customer metadata."
  @type metadata :: map() | nil

  @type t :: %__MODULE__{
          id: id(),
          dev_mode: dev_mode(),
          country: country(),
          name: name(),
          cellphone: cellphone(),
          tax_id: tax_id(),
          email: email(),
          zip_code: zip_code(),
          metadata: metadata()
        }

  @doc """
  Creates a new customer.

  ## Examples
      iex> AbacatePay.Customer.create([
        name: "Daniel Lima",
        cellphone: "(11) 4002-8922",
        email: "daniel_lima@abacatepay.com",
        tax_id: "123.456.789-01",
        zip_code: "12345-678",
        metadata: %{key: "value"}
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
            taxId: validated_options[:tax_id],
            zipCode: validated_options[:zip_code],
            metadata: validated_options[:metadata]
          }
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Enum.into(%{})

        with {:ok, response} <- Api.Customer.create(body) do
          build_struct(response)
        end

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, error}
    end
  end

  @doc """
  Gets a customer by ID.

  ## Examples
      iex> AbacatePay.Customer.get("cust_aebxkhDZNaMmJeKsy0AHS0FQ")
      {:ok, %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", ...}}

  Options: \n#{NimbleOptions.docs(Schema.Customer.list_customers_request())}
  """
  @spec get(customer_id :: id()) :: {:ok, t()} | {:error, ApiError.t()} | {:error, any()}
  def get(customer_id) do
    with {:ok, response} <- Api.Customer.get(customer_id) do
      build_struct(response)
    end
  end

  @doc """
  Gets a list of customers with pagination options.

  ## Examples
      iex> AbacatePay.Customer.list(page: 2, limit: 10)
      {:ok, [%AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", ...}, ...], %{page: 2, limit: 10}}
  """
  @spec list(options :: keyword()) ::
          {:ok, list(t()), map()} | {:error, ApiError.t()} | {:error, any()}
  def list(options) do
    {:ok, validated_options} =
      NimbleOptions.validate(options, Schema.Customer.list_customers_request())

    with {:ok, data_list, pagination} <-
           Api.Customer.list(%{page: validated_options[:page], limit: validated_options[:limit]}) do
      pretty_customers =
        data_list
        |> Enum.map(&build_struct/1)
        |> Enum.map(fn {:ok, customer} -> customer end)

      {:ok, pretty_pagination} = Pagination.build_struct(pagination)

      {:ok, pretty_customers, pretty_pagination}
    end
  end

  @doc """
  Gets a list of customers with default pagination (page: 1, limit: 20).

  ## Examples
      iex> AbacatePay.Customer.list()
      {:ok, [%AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", ...}, ...], %{page: 1, limit: 20}}
  """
  @spec list() :: {:ok, list(t()), map()} | {:error, ApiError.t()} | {:error, any()}
  def list do
    list(page: 1, limit: 20)
  end

  @doc """
  Builds a `AbacatePay.Customer` struct from raw API data.

  ## Examples
      iex> raw_data = %{
      ...>   "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   "name" => "Daniel Lima",
      ...>   "cellphone" => "(11) 4002-8922",
      ...>   "email" => "daniel_lima@abacatepay.com"
      ...>   "taxId" => "123.456.789-01",
      ...>   "devMode" => false,
      ...>   "country" => "BR",
      ...>   "zipCode" => "12345-678",
      ...>   "metadata" => %{"key" => "value"}
      ...> }
      iex> AbacatePay.Customer.build_struct(raw_data)
      {:ok, %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", ...}}
  """
  @spec build_struct(raw_data :: map()) :: {:ok, t()}
  def build_struct(raw_data) do
    pretty_fields = %AbacatePay.Customer{
      id: Map.get(raw_data, "id"),
      name: Map.get(raw_data, "name"),
      cellphone: Map.get(raw_data, "cellphone"),
      tax_id: Map.get(raw_data, "taxId"),
      email: Map.get(raw_data, "email"),
      dev_mode: Map.get(raw_data, "devMode"),
      country: Map.get(raw_data, "country"),
      zip_code: Map.get(raw_data, "zipCode"),
      metadata: build_struct_metadata(Map.get(raw_data, "metadata"))
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Customer` struct.

  ## Examples
      iex> customer = %AbacatePay.Customer{
      ...>   id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   name: "Daniel Lima",
      ...>   dev_mode: false,
      ...>   country: "BR",
      ...>   cellphone: "(11) 4002-8922",
      ...>   email: "daniel_lima@abacatepay.com",
      ...>   tax_id: "123.456.789-01",
      ...>   zip_code: "12345-678",
      ...>   metadata: %{key: "value"}
      ...> }
      iex> AbacatePay.Customer.build_raw(customer)
      {:ok, %{
        id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        name: "Daniel Lima",
        devMode: false,
        country: "BR",
        cellphone: "(11) 4002-8922",
        taxId: "123.456.789-01",
        email: "daniel_lima@abacatepay.com",
        zipCode: "12345-678",
        metadata: %{"key" => "value"}
      }}
  """
  @spec build_raw(customer :: t()) :: {:ok, map()}
  def build_raw(customer) do
    raw = %{
      id: customer.id,
      name: customer.name,
      devMode: customer.dev_mode,
      country: customer.country,
      cellphone: customer.cellphone,
      taxId: customer.tax_id,
      email: customer.email,
      zipCode: customer.zip_code,
      metadata: build_raw_metadata(customer.metadata)
    }

    {:ok, raw}
  end

  @doc false
  defp build_struct_metadata(nil), do: nil

  @doc false
  defp build_struct_metadata(metadata) when is_map(metadata),
    do: Map.new(metadata, fn {k, v} -> {String.to_atom(k), v} end)

  @doc false
  defp build_raw_metadata(nil), do: nil

  @doc false
  defp build_raw_metadata(metadata) when is_map(metadata),
    do: Map.new(metadata, fn {k, v} -> {Atom.to_string(k), v} end)
end
