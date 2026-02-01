defmodule AbacatePay.Pix do
  @moduledoc ~S"""
  Module that represents a Pix QR Code in AbacatePay.
  """

  alias AbacatePay.{Api, Customer, Schema, Util}

  defstruct [
    :id,
    :amount,
    :status,
    :dev_mode,
    :customer,
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

  @typedoc "Unique billing identifier."
  @type id :: String.t()

  @typedoc "Charge amount in cents (e.g. 4000 = R$40.00)."
  @type amount :: integer()

  @typedoc """
  Billing status. Can be one of the following:

  - `:pending` - The Pix QRCode is pending payment.
  - `:expired` - The Pix QRCode has expired.
  - `:cancelled` - The Pix QRCode has been cancelled.
  - `:paid` - The Pix QRCode has been paid.
  - `:refunded` - The Pix QRCode payment has been refunded.
  """
  @type status :: :pending | :expired | :cancelled | :paid | :refunded

  @typedoc "Indicates whether the charge is in a testing (true) or production (false) environment."
  @type dev_mode :: boolean()

  @typedoc "Customer associated with the Pix QRCode Payment."
  @type customer :: Customer.t() | nil

  @typedoc "PIX code (copy-and-paste) for payment."
  @type br_code :: String.t()

  @typedoc "PIX code in Base64 format (Useful for displaying in images)."
  @type br_code_base_64 :: String.t()

  @typedoc "Platform fee in cents. Example: 80 means R$0.80."
  @type platform_fee :: integer()

  @typedoc "Payment description."
  @type description :: String.t()

  @typedoc "QRCode PIX creation date and time."
  @type created_at :: DateTime.t()

  @typedoc "QRCode PIX last updated date and time."
  @type updated_at :: DateTime.t()

  @typedoc "QRCode expiration date and time."
  @type expires_at :: DateTime.t() | nil

  @type t :: %__MODULE__{
          id: id,
          amount: amount,
          status: status,
          dev_mode: dev_mode,
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
      iex> AbacatePay.Pix.create([
      ...>   amount: 123,
      ...>   description: "Payment for order #1234",
      ...>   customer: %AbacatePay.Customer{
      ...>     name: "Daniel Lima",
      ...>     email: "daniel_lima@abacatepay.com",
      ...>     tax_id: "123.456.789-01",
      ...>     phone: "(11) 4002-8922"
      ...>   },
      ...>   expires_in: 123,
      ...>   metadata: %{"external_id" => "123"}
      ...> ])
      {:ok, %AbacatePay.Pix{...}}

  Options: \n#{NimbleOptions.docs(Schema.Pix.create_pix_request())}
  """
  @spec create(options :: keyword()) :: {:ok, t()} | {:error, any()}
  def create(options) do
    case NimbleOptions.validate(options, Schema.Pix.create_pix_request()) do
      {:ok, validated_options} ->
        parsed_customer =
          with %Customer{} = customer_struct <- validated_options[:customer],
               {:ok, customer_map} <- Customer.build_api_customer(customer_struct) do
            customer_map.metadata
          else
            _ -> nil
          end

        body =
          %{
            amount: validated_options[:amount],
            description: validated_options[:description],
            customer: parsed_customer,
            expiresIn: validated_options[:expires_in],
            metadata: validated_options[:metadata]
          }
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Enum.into(%{})

        with {:ok, response} <- Api.Pix.create_pix_qrcode(body) do
          build_pretty_pix_qrcode(response)
        end

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, error}
    end
  end

  @doc """
  Simulates a payment for the Pix QR Code created in development mode

  ## Examples
      iex> AbacatePay.Pix.simulate_payment("pix_charabc123456789", %{})
      {:ok, %AbacatePay.Pix{...}}
  """
  @spec simulate_payment(id :: id(), metadata :: map()) ::
          {:ok, t()} | {:error, any()}
  def simulate_payment(id, metadata \\ %{}) do
    with {:ok, response} <- Api.Pix.simulate_payment(id, metadata) do
      build_pretty_pix_qrcode(response)
    end
  end

  @doc """
  Checks the status of a Pix QR Code by its ID.

  ## Examples
      iex> AbacatePay.Pix.check_status("pix_charabc123456789")
      {:ok, %AbacatePay.Pix{status: :pending, expires_at: "2026-01-01T12:00:00Z"}}
  """
  @spec check_status(id :: id()) :: {:ok, t()} | {:error, any()}
  def check_status(id) do
    with {:ok, response} <- Api.Pix.check_status(id) do
      build_pretty_pix_qrcode(response)
    end
  end

  @doc """
  Builds a `AbacatePay.Pix` struct from raw API data.

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
      iex> AbacatePay.Pix.build_pretty_pix_qrcode(raw_data)
      {:ok, %AbacatePay.Pix{
        id: "pix_charabc123456789",
        amount: 1500,
        status: :paid,
        dev_mode: false,
        br_code: "00020126360014BR.GOV.BCB.PIX0136+551199999999520400005303986540415005802BR5925Fulano de Tal6009Sao Paulo61080540900062070503***63041D3D",
        br_code_base_64: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAYAAAC0...",
        platform_fee: 80,
        description: "PIX Payment for order #1234",
        created_at: ~U[2026-01-01T12:00:00Z],
        updated_at: ~U[2026-01-01T12:05:00Z],
        expires_at: ~U[2026-01-02T12:00:00Z]
      }}
  """
  @spec build_pretty_pix_qrcode(raw_data :: map()) :: {:ok, t()}
  def build_pretty_pix_qrcode(raw_data) do
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

    expires_at =
      case raw_data["expiresAt"] do
        nil -> nil
        datetime_str -> DateTime.from_iso8601(datetime_str) |> elem(1)
      end

    pretty_fields = %AbacatePay.Pix{
      id: raw_data["id"],
      amount: raw_data["amount"],
      status: Util.atomize_enum(raw_data["status"]),
      dev_mode: raw_data["devMode"],
      br_code: raw_data["brCode"],
      br_code_base_64: raw_data["brCodeBase64"],
      platform_fee: raw_data["platformFee"],
      description: raw_data["description"],
      created_at: created_at,
      updated_at: updated_at,
      expires_at: expires_at
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Pix` struct.

  ## Examples
      iex> pix_qrcode = %AbacatePay.Pix{
      ...>   id: "pix_charabc123456789",
      ...>   amount: 1500,
      ...>   status: :paid,
      ...>   dev_mode: false,
      ...>   br_code: "00020126360014BR.GOV.BCB.PIX0136+551199999999520400005303986540415005802BR5925Fulano de Tal6009Sao Paulo61080540900062070503***63041D3D",
      ...>   br_code_base_64: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAYAAAC0...",
      ...>   platform_fee: 80,
      ...>   description: "PIX Payment for order #1234",
      ...>   created_at: ~U[2026-01-01T12:00:00Z],
      ...>   updated_at: ~U[2026-01-01T12:05:00Z],
      ...>   expires_at: ~U[2026-01-02T12:00:00Z]
      ...> }
      iex> AbacatePay.Pix.build_api_pix_qrcode(pix_qrcode)
      {:ok, %{
        id: "pix_charabc123456789",
        amount: 1500,
        status: "paid",
        devMode: false,
        brCode: "00020126360014BR.GOV.BCB.PIX0136+551199999999520400005303986540415005802BR5925Fulano de Tal6009Sao Paulo61080540900062070503***63041D3D",
        brCodeBase64: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAYAAAC0...",
        platformFee: 80,
        description: "PIX Payment for order #1234",
        createdAt: "2026-01-01T12:00:00Z",
        updatedAt: "2026-01-01T12:05:00Z",
        expiresAt: "2026-01-02T12:00:00Z"
      }}
  """
  @spec build_api_pix_qrcode(pretty_pix_qrcode :: t()) :: {:ok, map()}
  def build_api_pix_qrcode(pretty_pix_qrcode) do
    created_at =
      case pretty_pix_qrcode.created_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    updated_at =
      case pretty_pix_qrcode.updated_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    expires_at =
      case pretty_pix_qrcode.expires_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    api_fields = %{
      id: pretty_pix_qrcode.id,
      amount: pretty_pix_qrcode.amount,
      status: Util.normalize_atom(pretty_pix_qrcode.status),
      devMode: pretty_pix_qrcode.dev_mode,
      brCode: pretty_pix_qrcode.br_code,
      brCodeBase64: pretty_pix_qrcode.br_code_base_64,
      platformFee: pretty_pix_qrcode.platform_fee,
      description: pretty_pix_qrcode.description,
      createdAt: created_at,
      updatedAt: updated_at,
      expiresAt: expires_at
    }

    {:ok, api_fields}
  end
end
