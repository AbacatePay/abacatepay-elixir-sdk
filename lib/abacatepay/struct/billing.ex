defmodule AbacatePay.Billing do
  @moduledoc ~S"""
  Struct representing an AbacatePay billing.
  """

  alias AbacatePay.{Api, Customer, Product, Schema, Util}

  defstruct [
    :id,
    :frequency,
    :amount,
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

  @typedoc "Unique billing ID at AbacatePay."
  @type id :: String.t()

  @typedoc """
   Billing frequency. It can be:

  - `:one_time` - Billing that accepts a single payment from the same customer.
  - `:multiple_payments` - Billing in payment link mode, accepts multiple payments from different customers.
  """
  @type frequency :: :one_time | :multiple_payments

  @typedoc "Total amount of the billing in cents."
  @type amount :: integer()

  @typedoc "URL for your customer to make payment for the charge."
  @type url :: String.t()

  @typedoc """
  Billing status.

  - `:pending` - 	The billing is pending payment.
  - `:expired` - The payment time limit has been exceeded.
  - `:cancelled` - The billing was cancelled by you.
  - `:paid` - 	The billing was successfully paid by the customer.
  - `:refunded` - The amount was refunded to the customer.
  """
  @type status :: :pending | :expired | :cancelled | :paid | :refunded

  @typedoc "Indicates whether the charge was created in a development (true) or production (false) environment."
  @type dev_mode :: boolean()

  @typedoc """
  Supported payment types.

  - `:pix` - Payment via Pix.
  - `:card` - Payment via debit card.
  """
  @type methods :: [:pix | :card]

  @typedoc "List of products included in the charge. See structure reference `AbacatePay.Product`."
  @type products :: [Product.t()]

  @typedoc "Customer you are billing. Optional. See structure reference `AbacatePay.Customer`."
  @type customer :: Customer.t() | nil

  @typedoc """
  Object with metadata about the charge.

  - `fee` - Fee applied by AbacatePay.
  - `return_url` - URL that the customer will be redirected to when clicking the “back” button.
  - `completion_url` - URL that the customer will be redirected to when making payment.
  """
  @type metadata :: %{
          fee: integer(),
          return_url: String.t(),
          completion_url: String.t()
        }

  @typedoc "Date and time of next charge, or null for one-time charges."
  @type next_billing :: String.t() | nil

  @typedoc "Whether or not to allow coupons for billing."
  @type allow_coupons :: boolean()

  @typedoc "Coupons allowed in billing. Coupons are only considered if `allowCoupons` is true."
  @type coupons :: [String.t()] | nil

  @typedoc "Charge creation date and time."
  @type created_at :: DateTime.t()

  @typedoc "Charge last updated date and time."
  @type updated_at :: DateTime.t()

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

  @doc """
  Creates a new billing.

  ## Examples
      iex> AbacatePay.Billing.create([
        frequency: :one_time,
        methods: [:pix, :card],
        products: [
          %AbacatePay.Product{
            name: "Product 1",
            price: 5000,
            quantity: 1
          }
        ],
        return_url: "https://example.com/return",
        completion_url: "https://example.com/completion",
        customer: %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ"},
        allow_coupons: false
      ])
      {:ok, %AbacatePay.Billing{id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ", ...}}

  Options: \n#{NimbleOptions.docs(Schema.Billing.create_billing_request())}
  """
  @spec create(options :: keyword()) :: {:ok, t()} | {:error, any()}
  def create(options) do
    case NimbleOptions.validate(options, Schema.Billing.create_billing_request()) do
      {:ok, validated_options} ->
        parsed_methods =
          validated_options[:methods]
          |> Enum.map(&Util.normalize_atom/1)

        parsed_products =
          validated_options[:products]
          |> Enum.map(&Product.build_api_product/1)
          |> Enum.map(fn {:ok, product} -> product end)

        parsed_customer_id =
          case validated_options[:customer] do
            %Customer{id: id} -> id
            _ -> nil
          end

        parsed_customer =
          with %Customer{} = customer_struct <- validated_options[:customer],
               {:ok, customer_map} <- Customer.build_raw(customer_struct) do
            customer_map.metadata
          else
            _ -> nil
          end

        body =
          %{
            frequency: Util.normalize_atom(validated_options[:frequency]),
            methods: parsed_methods,
            products: parsed_products,
            returnUrl: validated_options[:return_url],
            completionUrl: validated_options[:completion_url],
            customer: parsed_customer,
            customerId: parsed_customer_id,
            allowCoupons: validated_options[:allow_coupons],
            metadata: validated_options[:metadata],
            coupons: validated_options[:coupons],
            externalId: validated_options[:external_id]
          }
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Enum.into(%{})

        with {:ok, response} <- Api.Billing.create_billing(body) do
          build_pretty_billing(response)
        end

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, error}
    end
  end

  @doc """
  Gets a list of all billings.

  ## Examples
      iex> AbacatePay.Billing.list()
      {:ok, [%AbacatePay.Billing{id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ", ...}, ...]}
  """
  @spec list() :: {:ok, [t()]} | {:error, any()}
  def list do
    with {:ok, data_list} <- Api.Billing.list_billings() do
      pretty_billings =
        data_list
        |> Enum.map(&build_pretty_billing/1)
        |> Enum.map(fn {:ok, billing} -> billing end)

      {:ok, pretty_billings}
    end
  end

  @doc """
  Builds a pretty billing struct from raw API data.

  ## Examples
      iex> raw_data = %{
      ...>   "id" => "bill_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   "frequency" => "ONE_TIME",
      ...>   "amount" => 1000,
      ...>   "url" => "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   "status" => "PENDING",
      ...>   "devMode" => true,
      ...>   "methods" => ["PIX", "CARD"],
      ...>   "products" => [...],
      ...>   "customer" => %{"id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...},
      ...>   "metadata" => %{"fee" => 80, "returnUrl" => "https://example.com/return", "completionUrl" => "https://example.com/completion"},
      ...>   "nextBilling" => nil,
      ...>   "allowCoupons" => false,
      ...>   "coupons" => nil,
      ...>   "createdAt" => "2026-01-01T12:00:00Z",
      ...>   "updatedAt" => "2026-01-02T12:00:00Z"
      ...> }
      iex> AbacatePay.Billing.build_pretty_billing(raw_data)
      {:ok, %AbacatePay.Billing{id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ", frequency: :one_time, ...}}
  """
  @spec build_pretty_billing(map()) :: {:ok, t()}
  def build_pretty_billing(raw_data) do
    pretty_metadata = %{
      fee: get_in(raw_data, ["metadata", "fee"]),
      return_url: get_in(raw_data, ["metadata", "returnUrl"]),
      completion_url: get_in(raw_data, ["metadata", "completionUrl"])
    }

    pretty_customer =
      with customer_data when is_map(customer_data) <- raw_data["customer"],
           {:ok, customer_struct} <- Customer.build_struct(customer_data) do
        customer_struct
      else
        _ -> nil
      end

    pretty_methods =
      raw_data["methods"]
      |> Enum.map(&Util.atomize_enum/1)

    pretty_products =
      raw_data["products"]
      |> Enum.map(&Product.build_pretty_product/1)
      |> Enum.map(fn {:ok, product} -> product end)

    pretty_created_at =
      case raw_data["createdAt"] do
        nil -> nil
        datetime_str -> DateTime.from_iso8601(datetime_str) |> elem(1)
      end

    pretty_updated_at =
      case raw_data["updatedAt"] do
        nil -> nil
        datetime_str -> DateTime.from_iso8601(datetime_str) |> elem(1)
      end

    pretty_fields = %AbacatePay.Billing{
      id: raw_data["id"],
      frequency: Util.atomize_enum(raw_data["frequency"]),
      amount: raw_data["amount"],
      url: raw_data["url"],
      status: Util.atomize_enum(raw_data["status"]),
      dev_mode: raw_data["devMode"],
      methods: pretty_methods,
      products: pretty_products,
      customer: pretty_customer,
      metadata: pretty_metadata,
      next_billing: raw_data["nextBilling"],
      allow_coupons: raw_data["allowCoupons"],
      coupons: raw_data["coupons"],
      created_at: pretty_created_at,
      updated_at: pretty_updated_at
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Billing` struct.

  ## Examples
      iex> billing = %AbacatePay.Billing{
      ...>   frequency: :one_time,
      ...>   amount: 1000,
      ...>   url: "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
      ...>   status: :pending,
      ...>   dev_mode: true,
      ...>   methods: [:pix, :card],
      ...>   products: [...],
      ...>   customer: %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...},
      ...>   metadata: %{"fee" => 80, "return_url" => "https://example.com/return", "completion_url" => "https://example.com/completion"},
      ...>   next_billing: nil,
      ...>   allow_coupons: false,
      ...>   coupons: nil,
      ...>   created_at: ~U[2026-01-01T12:00:00Z],
      ...>   updated_at: ~U[2026-01-02T12:00:00Z]
      ...> }
      iex> AbacatePay.Billing.build_api_billing(billing)
      {:ok, %{
        frequency: "ONE_TIME",
        amount: 1000,
        url: "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
        status: "PENDING",
        devMode: true,
        methods: ["PIX", "CARD"],
        products: [...],
        customer: %{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...},
        metadata: %{"fee" => 80, "returnUrl" => "https://example.com/return", "completionUrl" => "https://example.com/completion"},
        nextBilling: nil,
        allowCoupons: false,
        coupons: nil,
        createdAt: "2026-01-01T12:00:00Z",
        updatedAt: "2026-01-02T12:00:00Z"
      }}
  """
  @spec build_api_billing(pretty_billing :: t()) :: {:ok, map()}
  def build_api_billing(pretty_billing) do
    customer =
      with %Customer{} = customer_struct <- pretty_billing.customer,
           {:ok, customer_map} <- Customer.build_raw(customer_struct) do
        customer_map
      else
        _ -> nil
      end

    products =
      pretty_billing.products
      |> Enum.map(&Product.build_api_product/1)
      |> Enum.map(fn {:ok, product} -> product end)

    methods =
      pretty_billing.methods
      |> Enum.map(&Util.normalize_atom/1)

    created_at =
      case pretty_billing.created_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    updated_at =
      case pretty_billing.updated_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    metadata =
      case pretty_billing.metadata do
        nil ->
          nil

        metadata_struct ->
          %{
            "fee" => metadata_struct.fee,
            "returnUrl" => metadata_struct.return_url,
            "completionUrl" => metadata_struct.completion_url
          }
      end

    api_fields = %{
      id: pretty_billing.id,
      frequency: Util.normalize_atom(pretty_billing.frequency),
      amount: pretty_billing.amount,
      url: pretty_billing.url,
      status: Util.normalize_atom(pretty_billing.status),
      devMode: pretty_billing.dev_mode,
      methods: methods,
      products: products,
      customer: customer,
      metadata: metadata,
      nextBilling: pretty_billing.next_billing,
      allowCoupons: pretty_billing.allow_coupons,
      coupons: pretty_billing.coupons,
      createdAt: created_at,
      updatedAt: updated_at
    }

    {:ok, api_fields}
  end
end
