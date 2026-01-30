defmodule AbacatePay.Billing do
  @moduledoc ~S"""
  Module that represents a billing in AbacatePay.
  """

  alias AbacatePay.{Api, Customer, Product}

  defstruct [
    :id,
    :frequency,
    :url,
    :status,
    :dev_mode,
    :methods,
    :products,
    :customer,
    :metadata,
    :next_billing,
    :allow_coupons,
    :coupons,
    :created_at,
    :updated_at
  ]

  @typedoc "Unique identifier of the billing."
  @type id :: String.t()

  @typedoc """
  The billing frequency. Defaults to `:one_time`.

  - `:one_time` - Billing that accepts a single payment from the same customer.
  - `:multiple_payments` - Billing in payment link mode, accepts multiple payments from different customers.
  """
  @type frequency :: :one_time | :multiple_payments

  @typedoc "The URL which the user can complete the payment."
  @type url :: String.t()

  @typedoc """
  The current billing status.

  - `:pending` - 	The billing is pending payment.
  - `:expired` - The payment time limit has been exceeded.
  - `:cancelled` - The billing was cancelled by you.
  - `:paid` - 	The billing was successfully paid by the customer.
  - `:refunded` - The amount was refunded to the customer.
  """
  @type status :: :pending | :expired | :cancelled | :paid | :refunded

  @typedoc "Indicates if it's operating in dev mode."
  @type dev_mode :: boolean()

  @typedoc """
  The allowed methods for the billing.

  - `:pix` - Payment via Pix.
  - `:card` - Payment via debit card.
  """
  @type methods :: [:pix | :card]

  @typedoc "The list of products in the billing."
  @type products :: [Product.t()]

  @typedoc "The data of the customer that the billing belongs to."
  @type customer :: Customer.t() | nil

  @typedoc """
  The billing metadata.

  - `:fee` - Fee applied by AbacatePay.
  - `:return_url` - URL to which the customer will be redirected when clicking the "back" button.
  - `:completion_url` - URL to which the customer will be redirected after making the payment.
  """
  @type metadata :: %{
          fee: integer(),
          return_url: String.t(),
          completion_url: String.t()
        }

  @typedoc "Date and time of the next billing."
  @type next_billing :: String.t() | nil

  @typedoc "If the billing has allowed coupons or not."
  @type allow_coupons :: boolean()

  @typedoc "The available coupons."
  @type coupons :: [String.t()] | nil

  @typedoc "The date and time when the billing was created."
  @type created_at :: String.t()

  @typedoc "The date and time of the last billing update."
  @type updated_at :: String.t()

  @type t :: %__MODULE__{
          id: id,
          frequency: frequency,
          url: url,
          status: status,
          dev_mode: dev_mode,
          methods: methods,
          products: products,
          customer: customer,
          metadata: metadata,
          next_billing: next_billing,
          allow_coupons: allow_coupons,
          coupons: coupons,
          created_at: created_at,
          updated_at: updated_at
        }

  # TODO: create billing implementation
  def create() do
  end

  @doc """
  Gets a list of all billings.

  ## Examples

      iex> AbacatePay.Billing.list()
      {:ok, [%AbacatePay.Billing{id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ", ...}, ...]}
  """
  def list do
    case Api.Billing.list_billings() do
      {:ok, data_list} ->
        data_list
        |> Enum.map(&build_pretty_billing/1)
        |> Enum.map(fn {:ok, billing} -> billing end)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Builds a pretty billing struct from raw API data.

  ## Examples

      iex> raw_data = %{
      ...>   "id" => "bill_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   "frequency" => :one_time,
      ...>   "url" => "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   "status" => :pending,
      ...>   "devMode" => true,
      ...>   "methods" => [:pix, :card],
      ...>   "products" => [...],
      ...>   "customer" => %{"id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...},
      ...>   "metadata" => %{"fee" => 100, "return_url" => "https://example.com/return", "completion_url" => "https://example.com/completion"},
      ...>   "nextBilling" => nil,
      ...>   "allowCoupons" => false,
      ...>   "coupons" => nil,
      ...>   "createdAt" => "2024-01-01T12:00:00Z",
      ...>   "updatedAt" => "2024-01-02T12:00:00Z"
      ...> }
      iex> AbacatePay.Billing.build_pretty_billing(raw_data)
      {:ok, %AbacatePay.Billing{id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ", frequency: :one_time, ...}}
  """
  @spec build_pretty_billing(map()) :: {:ok, t()}
  def build_pretty_billing(raw_data) do
    pretty_fields = %AbacatePay.Billing{
      id: Map.get(raw_data, "id"),
      frequency:
        Map.get(raw_data, "frequency")
        |> Atom.to_string()
        |> Macro.underscore()
        |> String.to_atom(),
      url: Map.get(raw_data, "url"),
      status:
        Map.get(raw_data, "status")
        |> Atom.to_string()
        |> Macro.underscore()
        |> String.to_atom(),
      dev_mode: Map.get(raw_data, "devMode"),
      methods:
        Map.get(raw_data, "methods")
        |> Enum.map(fn method ->
          method
          |> Atom.to_string()
          |> Macro.underscore()
          |> String.to_atom()
        end),
      products:
        Map.get(raw_data, "products")
        |> Enum.map(&Product.build_pretty_product/1),
      customer:
        case Map.get(raw_data, "customer") do
          nil -> nil
          customer_data -> Customer.build_pretty_customer(customer_data)
        end,
      metadata: Map.get(raw_data, "metadata"),
      next_billing: Map.get(raw_data, "nextBilling"),
      allow_coupons: Map.get(raw_data, "allowCoupons"),
      coupons: Map.get(raw_data, "coupons"),
      created_at: Map.get(raw_data, "createdAt"),
      updated_at: Map.get(raw_data, "updatedAt")
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Billing` struct.

  ## Examples

      iex> billing = %AbacatePay.Billing{
      ...>   frequency: :one_time,
      ...>   url: "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   status: :pending,
      ...>   dev_mode: true,
      ...>   methods: [:pix, :card],
      ...>   products: [...],
      ...>   customer: %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...},
      ...>   metadata: %{"fee" => 100, "return_url" => "https://example.com/return", "completion_url" => "https://example.com/completion"},
      ...>   next_billing: nil,
      ...>   allow_coupons: false,
      ...>   coupons: nil,
      ...>   created_at: "2024-01-01T12:00:00Z",
      ...>   updated_at: "2024-01-02T12:00:00Z"
      ...> }
      iex> AbacatePay.Billing.build_api_billing(billing)
      {:ok, %{
        frequency: :ONE_TIME,
        url: "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
        status: :PENDING,
        devMode: true,
        methods: [:PIX, :CARD],
        products: [...],
        customer: %{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...},
        metadata: %{"fee" => 100, "return_url" => "https://example.com/return", "completion_url" => "https://example.com/completion"},
        nextBilling: nil,
        allowCoupons: false,
        coupons: nil,
        createdAt: "2024-01-01T12:00:00Z",
        updatedAt: "2024-01-02T12:00:00Z"
      }}
  """
  @spec build_api_billing(pretty_billing :: t()) :: {:ok, map()}
  def build_api_billing(pretty_billing) do
    api_fields = %{
      frequency:
        pretty_billing.frequency
        |> Atom.to_string()
        |> String.upcase()
        |> String.to_atom(),
      url: pretty_billing.url,
      status:
        pretty_billing.status
        |> Atom.to_string()
        |> String.upcase()
        |> String.to_atom(),
      devMode: pretty_billing.dev_mode,
      methods:
        pretty_billing.methods
        |> Enum.map(fn method ->
          method
          |> Atom.to_string()
          |> String.upcase()
          |> String.to_atom()
        end),
      products:
        pretty_billing.products
        |> Enum.map(&Product.build_api_product/1)
        |> Enum.map(fn {:ok, product} -> product end),
      customer:
        case pretty_billing.customer do
          nil ->
            nil

          customer_struct ->
            case Customer.build_api_customer(customer_struct) do
              {:ok, customer_map} -> customer_map
            end
        end,
      metadata: pretty_billing.metadata,
      nextBilling: pretty_billing.next_billing,
      allowCoupons: pretty_billing.allow_coupons,
      coupons: pretty_billing.coupons,
      createdAt: pretty_billing.created_at,
      updatedAt: pretty_billing.updated_at
    }

    {:ok, api_fields}
  end
end
