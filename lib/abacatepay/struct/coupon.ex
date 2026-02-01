defmodule AbacatePay.Coupon do
  @moduledoc ~S"""
  Module that represents a coupon in AbacatePay.
  """

  alias AbacatePay.{Api, Schema, Util}

  defstruct [
    :id,
    :discount_kind,
    :discount,
    :max_redeems,
    :redeems_count,
    :status,
    :dev_mode,
    :metadata,
    :notes,
    :created_at,
    :updated_at
  ]

  @typedoc "Unique coupon code that your customers will use to apply the discount."
  @type id :: String.t()

  @typedoc """
  Type of discount applied by the coupon.

  - `:percentage` - Percentual discount (e.g. 10% off).
  - `:fixed` - Fixed amount discount (e.g. R$ 5,00 off).
  """
  @type discount_kind :: :percentage | :fixed

  @typedoc """
  Discount amount.

  For :percentage use numbers from 1-100 (e.g. 10 = 10%). For :fixed use the value in cents (e.g. 500 = R$ 5,00)
  """
  @type discount :: integer()

  @typedoc "Limit on the number of times the coupon can be used. Use `-1` for unlimited coupons or a specific number to limit usage."
  @type max_redeems :: integer()

  @typedoc "Counter of how many times the coupon has been used by customers."
  @type redeems_count :: non_neg_integer()

  @typedoc """
  Coupon status.

  - `:active` - The coupon is active and can be used by customers.
  - `:deleted` - The coupon has been removed and can no longer be used.
  - `:disabled` - The coupon has been disabled or has reached its maximum usage limit.
  """
  @type status :: :active | :deleted | :disabled

  @typedoc "Indicates whether the coupon was created in a development (true) or production (false) environment."
  @type dev_mode :: boolean()

  @typedoc "Additional metadata associated with the coupon."
  @type metadata :: map() | nil

  @typedoc "Internal description of the coupon for your organization and control."
  @type notes :: String.t() | nil

  @typedoc "Coupon creation date and time."
  @type created_at :: DateTime.t()

  @typedoc "Coupon last updated date and time."
  @type updated_at :: DateTime.t()

  @type t :: %__MODULE__{
          id: id,
          discount_kind: discount_kind,
          discount: discount,
          max_redeems: max_redeems,
          redeems_count: redeems_count,
          status: status,
          dev_mode: dev_mode,
          metadata: metadata,
          notes: notes,
          created_at: created_at,
          updated_at: updated_at
        }

  @doc """
  Creates a new coupon.

  ## Examples
      iex> AbacatePay.Coupon.create([
        code: "DEYVIN_20",
        discount_kind: :percentage,
        discount: 123,
        max_redeems: 100
      ])
      {:ok, %AbacatePay.Coupon{id: "DEYVIN_20", ...}}

  Options: \n#{NimbleOptions.docs(Schema.Coupon.create_coupon_request())}
  """
  @spec create(options :: keyword()) :: {:ok, t()} | {:error, any()}
  def create(options) do
    case NimbleOptions.validate(options, Schema.Coupon.create_coupon_request()) do
      {:ok, validated_options} ->
        body =
          %{
            code: validated_options[:code],
            discountKind: Util.normalize_atom(validated_options[:discount_kind]),
            discount: validated_options[:discount],
            notes: validated_options[:notes],
            maxRedeems: validated_options[:max_redeems],
            metadata: validated_options[:metadata]
          }
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Enum.into(%{})

        with {:ok, response} <- Api.Coupon.create_coupon(body) do
          build_pretty_coupon(response)
        end

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, error}
    end
  end

  @doc """
  Lists all coupons.

  ## Examples
      iex> AbacatePay.Coupon.list()
      [
        %AbacatePay.Coupon{...},
        %AbacatePay.Coupon{...}
      ]
  """
  def list do
    with {:ok, data_list} <- Api.Coupon.list_coupons() do
      pretty_coupons =
        data_list
        |> Enum.map(&build_pretty_coupon/1)
        |> Enum.map(fn {:ok, coupon} -> coupon end)

      {:ok, pretty_coupons}
    end
  end

  @doc """
  Builds a pretty coupon struct from raw API data.

  ## Examples
      iex> raw_data = %{
      ...>   "id" => "coupon_123",
      ...>   "discountKind" => "PERCENTAGE",
      ...>   "discount" => 10.0,
      ...>   "maxRedeems" => 100,
      ...>   "redeemsCount" => 5,
      ...>   "status" => "ACTIVE",
      ...>   "devMode" => false,
      ...>   "notes" => "10% off on all products",
      ...>   "createdAt" => "2026-01-01T00:00:00Z",
      ...>   "updatedAt" => "2026-01-10T00:00:00Z"
      ...> }
      iex> AbacatePay.Coupon.build_pretty_coupon(raw_data)
      {:ok, %AbacatePay.Coupon{
        id: "coupon_123",
        discount_kind: :percentage,
        discount: 10.0,
        max_redeems: 100,
        redeems_count: 5,
        status: :active,
        dev_mode: false,
        notes: "10% off on all products",
        created_at: ~U[2026-01-01T00:00:00Z],
        updated_at: ~U[2026-01-10T00:00:00Z]
      }}
  """
  @spec build_pretty_coupon(raw_data :: map()) :: {:ok, t()}
  def build_pretty_coupon(raw_data) do
    created_at =
      case raw_data["createdAt"] do
        nil -> nil
        datetime_str -> DateTime.from_iso8601(datetime_str) |> elem(1)
      end

    updated_at =
      case raw_data["updatedAt"] do
        nil -> nil
        datetime_str -> DateTime.from_iso8601(datetime_str) |> elem(1)
      end

    pretty_fields = %AbacatePay.Coupon{
      id: raw_data["id"],
      discount_kind: Util.atomize_enum(raw_data["discountKind"]),
      discount: raw_data["discount"],
      max_redeems: raw_data["maxRedeems"],
      redeems_count: raw_data["redeemsCount"],
      status: Util.atomize_enum(raw_data["status"]),
      dev_mode: raw_data["devMode"],
      metadata: raw_data["metadata"],
      notes: raw_data["notes"],
      created_at: created_at,
      updated_at: updated_at
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Coupon` struct

  ## Examples
      iex> coupon = %AbacatePay.Coupon{
      ...>   id: "coupon_123",
      ...>   discount_kind: :percentage,
      ...>   discount: 10.0,
      ...>   max_redeems: 100,
      ...>   redeems_count: 5,
      ...>   status: :active,
      ...>   dev_mode: false,
      ...>   notes: "10% off on all products",
      ...>   created_at: ~U[2026-01-01T00:00:00Z],
      ...>   updated_at: ~U[2026-01-10T00:00:00Z]
      ...> }
      iex> AbacatePay.Coupon.build_api_coupon(coupon)
      {:ok, %{
        id: "coupon_123",
        discountKind: "PERCENTAGE",
        discount: 10.0,
        maxRedeems: 100,
        status: "ACTIVE",
        devMode: false,
        notes: "10% off on all products",
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-01-10T00:00:00Z"
      }}
  """
  @spec build_api_coupon(pretty_coupon :: t()) :: {:ok, map()}
  def build_api_coupon(pretty_coupon) do
    created_at =
      case pretty_coupon.created_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    updated_at =
      case pretty_coupon.updated_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    api_fields = %{
      id: pretty_coupon.id,
      discountKind: Util.normalize_atom(pretty_coupon.discount_kind),
      discount: pretty_coupon.discount,
      maxRedeems: pretty_coupon.max_redeems,
      status: Util.normalize_atom(pretty_coupon.status),
      devMode: pretty_coupon.dev_mode,
      metadata: pretty_coupon.metadata,
      notes: pretty_coupon.notes,
      createdAt: created_at,
      updatedAt: updated_at
    }

    {:ok, api_fields}
  end
end
