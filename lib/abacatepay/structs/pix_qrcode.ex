defmodule AbacatePay.PixQrCode do
  @moduledoc ~S"""
  Module that represents a Pix QR Code in AbacatePay.
  """

  alias AbacatePay.{Api, Customer}

  defstruct [
    :id,
    :amount,
    :status,
    :dev_mode,
    :customer,
    :method,
    :br_code,
    :br_code_base_64,
    :platform_fee,
    :description,
    :created_at,
    :updated_at,
    :metadata,
    :expires_at,
    :expires_in
  ]

  @typedoc "Unique identifier of the Pix QRCode."
  @type id :: String.t()

  @typedoc "Amount to be paid."
  @type amount :: integer()

  @typedoc """
  Information about the status of the Pix QRCode.

  - `:pending` - The Pix QRCode is pending payment.
  - `:expired` - The Pix QRCode has expired.
  - `:cancelled` - The Pix QRCode has been cancelled.
  - `:paid` - The Pix QRCode has been paid.
  - `:refunded` - The Pix QRCode payment has been refunded.
  """
  @type status :: :pending | :expired | :cancelled | :paid | :refunded

  @typedoc "Indicates if the Pix QRCode is in development mode."
  @type dev_mode :: boolean()

  @typedoc "Customer associated with the Pix QRCode Payment."
  @type customer :: Customer.t() | nil

  @typedoc "Payment method used (always `:pix`)."
  @type method :: :pix

  @typedoc "Copy-and-paste code of the Pix QRCode."
  @type br_code :: String.t()

  @typedoc "Base64 encoded image of the Pix QRCode."
  @type br_code_base_64 :: String.t()

  @typedoc "Platform fees."
  @type platform_fee :: integer()

  @typedoc "A description for the Pix QR Code."
  @type description :: String.t()

  @typedoc "Creation date of the Pix QRCode."
  @type created_at :: String.t()

  @typedoc "Update date of the Pix QRCode."
  @type updated_at :: String.t()

  @typedoc "Expiration date of the Pix QRCode."
  @type expires_at :: String.t()

  @type t :: %__MODULE__{
          id: id,
          amount: amount,
          status: status,
          dev_mode: dev_mode,
          method: method,
          br_code: br_code,
          br_code_base_64: br_code_base_64,
          platform_fee: platform_fee,
          description: description,
          created_at: created_at,
          updated_at: updated_at,
          expires_at: expires_at
        }

  @doc """
  Creates a new Pix QR Code.

  ## Examples

      iex> pix_qrcode = %AbacatePay.PixQrCode{
      ...>   amount: 1500,
      }
      iex> AbacatePay.PixQrCode.create(pix_qrcode)
      {:ok, %AbacatePay.PixQrCode{...}}
  """
  @spec create(pix_qrcode :: t()) :: {:ok, t()} | {:error, any()}
  def create(%__MODULE__{
        amount: amount,
        description: description,
        customer: customer,
        expires_in: expires_in,
        metadata: metadata
      }) do
    parsed_customer =
      with %Customer{} = customer_struct <- customer,
           {:ok, customer_map} <- Customer.build_api_customer(customer_struct) do
        Map.get(customer_map, :metadata)
      else
        _ -> nil
      end

    body =
      %{
        amount: amount,
        description: description,
        customer: parsed_customer,
        expiresIn: expires_in,
        metadata: metadata
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    case Api.PixQrCode.create_pix_qrcode(body) do
      {:ok, data} ->
        build_pretty_pix_qrcode(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Simulates a payment for the Pix QR Code created in development mode with metadata.

  ## Examples

      iex> pix_qrcode = %AbacatePay.PixQrCode{
      ...>   id: "pix_charabc123456789",
      ...>   metadata: %{custom_key: "custom_value"}
      ...> }
      iex> AbacatePay.PixQrCode.simulate_payment(pix_qrcode)
      {:ok, %AbacatePay.PixQrCode{...}}

      iex> pix_qrcode = %AbacatePay.PixQrCode{
      ...>   id: "pix_charabc123456789"
      ...> }
      iex> AbacatePay.PixQrCode.simulate_payment(pix_qrcode)
      {:ok, %AbacatePay.PixQrCode{...}}
  """
  @spec simulate_payment(pix_qrcode :: t()) :: {:ok, t()} | {:error, any()}
  def simulate_payment(%__MODULE__{id: id, metadata: metadata}) do
    case Api.PixQrCode.simulate_payment(id, metadata) do
      {:ok, data} ->
        build_pretty_pix_qrcode(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Checks the status of a Pix QR Code by its ID.

  ## Examples

      iex> pix_qrcode = %AbacatePay.PixQrCode{
      ...>   id: "pix_charabc123456789"
      ...> }
      iex> AbacatePay.PixQrCode.check_status(pix_qrcode)
      {:ok, %AbacatePay.PixQrCode{status: :pending, expires_at: "2026-01-01T12:00:00Z"}}
  """
  @spec check_status(pix_qrcode :: t()) :: {:ok, t()} | {:error, any()}
  def check_status(%__MODULE__{id: id}) do
    case Api.PixQrCode.check_status(id) do
      {:ok, data} ->
        build_pretty_pix_qrcode(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Builds a `AbacatePay.PixQrCode` struct from raw API data.

  ## Examples

      iex> raw_data = %{
      ...>   "id" => "pix_charabc123456789",
      ...>   "amount" => 1500,
      ...>   "status" => "paid",
      ...>   "devMode" => false,
      ...>   "brCode" => "00020126360014BR.GOV.BCB.PIX0136+551199999999520400005303986540415005802BR5925Fulano de Tal6009Sao Paulo61080540900062070503***63041D3D",
      ...>   "brCodeBase64" => "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAYAAAC0...",
      ...>   "platformFee" => 80,
      ...>   "description" => "PIX Payment for order #1234",
      ...>   "createdAt" => "2026-01-01T12:00:00Z",
      ...>   "updatedAt" => "2026-01-01T12:05:00Z",
      ...>   "expiresAt" => "2026-01-02T12:00:00Z"
      ...> }
      iex> AbacatePay.PixQrCode.build_pretty_pix_qrcode(raw_data)
      {:ok, %AbacatePay.PixQrCode{
        id: "pix_charabc123456789",
        amount: 1500,
        status: :paid,
        dev_mode: false,
        method: :pix,
        br_code: "00020126360014BR.GOV.BCB.PIX0136+551199999999520400005303986540415005802BR5925Fulano de Tal6009Sao Paulo61080540900062070503***63041D3D",
        br_code_base_64: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAYAAAC0...",
        platform_fee: 80,
        description: "PIX Payment for order #1234",
        created_at: "2026-01-01T12:00:00Z",
        updated_at: "2026-01-01T12:05:00Z",
        expires_at: "2026-01-02T12:00:00Z"
      }}
  """
  @spec build_pretty_pix_qrcode(raw_data :: map()) :: {:ok, t()}
  def build_pretty_pix_qrcode(raw_data) do
    pretty_fields = %AbacatePay.PixQrCode{
      id: Map.get(raw_data, "id"),
      amount: Map.get(raw_data, "amount"),
      status:
        Map.get(raw_data, "status")
        |> Macro.underscore()
        |> String.to_existing_atom(),
      dev_mode: Map.get(raw_data, "devMode"),
      # The method is always :pix for Pix QR Codes, so we can hardcode it
      method: :pix,
      br_code: Map.get(raw_data, "brCode"),
      br_code_base_64: Map.get(raw_data, "brCodeBase64"),
      platform_fee: Map.get(raw_data, "platformFee"),
      description: Map.get(raw_data, "description"),
      created_at: Map.get(raw_data, "createdAt"),
      updated_at: Map.get(raw_data, "updatedAt"),
      expires_at: Map.get(raw_data, "expiresAt")
    }

    {:ok, pretty_fields}
  end

  @spec build_api_pix_qrcode(pretty_pix_qrcode :: t()) :: {:ok, map()}
  def build_api_pix_qrcode(pretty_pix_qrcode) do
    api_fields = %{
      id: pretty_pix_qrcode.id,
      amount: pretty_pix_qrcode.amount,
      status:
        pretty_pix_qrcode.status
        |> Atom.to_string()
        |> String.upcase(),
      devMode: pretty_pix_qrcode.dev_mode,
      # The method is always "pix" for Pix QR Codes, so we can hardcode it
      method: "pix",
      brCode: pretty_pix_qrcode.br_code,
      brCodeBase64: pretty_pix_qrcode.br_code_base_64,
      platformFee: pretty_pix_qrcode.platform_fee,
      description: pretty_pix_qrcode.description,
      createdAt: pretty_pix_qrcode.created_at,
      updatedAt: pretty_pix_qrcode.updated_at,
      expiresAt: pretty_pix_qrcode.expires_at
    }

    {:ok, api_fields}
  end
end
