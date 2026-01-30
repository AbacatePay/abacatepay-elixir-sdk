defmodule AbacatePay.Coupon do
  @moduledoc ~S"""
  Module that represents a coupon in AbacatePay.
  """

  alias AbacatePay.Api

  defstruct [
    :id,
    :discount_kind,
    :discount,
    :max_redeems,
    :redeems_count,
    :status,
    :dev_mode,
    :notes,
    :created_at,
    :updated_at
  ]

  @typedoc "The unique identifier for the coupon."
  @type id :: String.t()

  @typedoc """
  The type of discount (e.g., percentage or fixed amount).

  - `:percentage` - Percentual discount (e.g. 10% off).
  - `:fixed` - Fixed amount discount (e.g. R$ 5,00 off).
  """
  @type discount_kind :: :percentage | :fixed

  @typedoc """
  The value of the discount.

  For :percentage use numbers from 1-100 (e.g. 10 = 10%). For :fixed use the value in cents (e.g. 500 = R$ 5,00)
  """
  @type discount :: float()

  @typedoc "The maximum number of times the coupon can be redeemed."
  @type max_redeems :: integer()

  @typedoc "The number of times the coupon has been redeemed."
  @type redeems_count :: non_neg_integer()

  @typedoc """
  The current status of the coupon (e.g., `:active`, `:deleted`, `:disabled`).

  - `:active` - The coupon is active and can be used by customers.
  - `:deleted` - The coupon has been removed and can no longer be used.
  - `:disabled` - The coupon has been disabled or has reached its maximum usage limit.
  """
  @type status :: :active | :deleted | :disabled

  @typedoc "Indicates if the coupon is in development mode."
  @type dev_mode :: boolean()

  @typedoc "Coupon's description"
  @type notes :: String.t()

  @typedoc "Timestamp when the coupon was created."
  @type created_at :: String.t()

  @typedoc "Timestamp when the coupon was last updated."
  @type updated_at :: String.t()

  @type t :: %__MODULE__{
          id: id,
          discount_kind: discount_kind,
          discount: discount,
          max_redeems: max_redeems,
          redeems_count: redeems_count,
          status: status,
          dev_mode: dev_mode,
          notes: notes,
          created_at: created_at,
          updated_at: updated_at
        }

  @doc """
  Creates a new coupon.

  ## Examples

      iex> coupon = %AbacatePay.Coupon{
      ...>   id: "DEYVIN_20",
      ...>   discount_kind: :percentage,
      ...>   discount: 10.0,
      ...>   notes: "10% off on all products",
      ...>   max_redeems: 100
      ...> }
      iex> AbacatePay.Coupon.create(coupon)
      {:ok, %AbacatePay.Coupon{...}}
  """
  @spec create(coupon :: t()) :: {:ok, t()} | {:error, any()}
  def create(%__MODULE__{
        id: id,
        discount_kind: discount_kind,
        discount: discount,
        notes: notes,
        max_redeems: max_redeems
      }) do
    body =
      %{
        code: id,
        discountKind:
          discount_kind
          |> Atom.to_string()
          |> String.upcase(),
        discount: discount,
        notes: notes,
        maxRedeems: max_redeems
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    case Api.Coupon.create_coupon(body) do
      {:ok, data} ->
        build_pretty_coupon(data)

      {:error, reason} ->
        {:error, reason}
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
    case Api.Coupon.list_coupons() do
      {:ok, data_list} ->
        data_list
        |> Enum.map(&build_pretty_coupon/1)
        |> Enum.map(fn {:ok, coupon} -> coupon end)

      {:error, reason} ->
        {:error, reason}
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
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-10T00:00:00Z"
      }}
  """
  @spec build_pretty_coupon(raw_data :: map()) :: {:ok, t()}
  def build_pretty_coupon(raw_data) do
    pretty_fields = %AbacatePay.Coupon{
      id: Map.get(raw_data, "id"),
      discount_kind:
        Map.get(raw_data, "discountKind")
        |> Macro.underscore()
        |> String.to_existing_atom(),
      discount: Map.get(raw_data, "discount"),
      max_redeems: Map.get(raw_data, "maxRedeems"),
      redeems_count: Map.get(raw_data, "redeemsCount"),
      status:
        Map.get(raw_data, "status")
        |> Macro.underscore()
        |> String.to_existing_atom(),
      dev_mode: Map.get(raw_data, "devMode"),
      notes: Map.get(raw_data, "notes"),
      created_at: Map.get(raw_data, "createdAt"),
      updated_at: Map.get(raw_data, "updatedAt")
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
      ...>   created_at: "2026-01-01T00:00:00Z",
      ...>   updated_at: "2026-01-10T00:00:00Z"
      ...> }
      iex> AbacatePay.Coupon.build_api_coupon(coupon)
      {:ok, %{
        id: "coupon_123",
        discountKind: "PERCENTAGE",
        discount: 10.0,
        maxRedeems: 100,
        status: "ACTIVE",
        devMode: false,
        notes: "10% off on all products"
      }}
  """
  @spec build_api_coupon(pretty_coupon :: t()) :: {:ok, map()}
  def build_api_coupon(pretty_coupon) do
    api_fields = %{
      id: pretty_coupon.id,
      discountKind:
        pretty_coupon.discount_kind
        |> Atom.to_string()
        |> String.upcase(),
      discount: pretty_coupon.discount,
      maxRedeems: pretty_coupon.max_redeems,
      status:
        pretty_coupon.status
        |> Atom.to_string()
        |> String.upcase(),
      devMode: pretty_coupon.dev_mode,
      notes: pretty_coupon.notes
    }

    {:ok, api_fields}
  end
end
