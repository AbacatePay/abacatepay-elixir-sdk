defmodule AbacatePay.Withdraw do
  @moduledoc ~S"""
  Module that represents a withdraw in AbacatePay.
  """

  alias AbacatePay.Api

  defstruct [
    :id,
    :status,
    :description,
    :dev_mode,
    :receipt_url,
    :method,
    :kind,
    :amount,
    :platform_fee,
    :external_id,
    :created_at,
    :pix,
    :updated_at
  ]

  @typedoc "The unique identifier for the withdraw."
  @type id :: String.t()

  @typedoc """
  The current status of the withdraw.

  - `:pending` - The withdraw is pending processing.
  - `:expired` - The withdraw request has expired.
  - `:cancelled` - The withdraw has been cancelled.
  - `:complete` - The withdraw has been completed successfully.
  - `:refunded` - The withdraw has been refunded.
  """
  @type status :: :pending | :expired | :cancelled | :complete | :refunded

  @typedoc "A description of the withdraw."
  @type description :: String.t() | nil

  @typedoc "Indicates if the withdraw is in development mode."
  @type dev_mode :: boolean()

  @typedoc "URL to the withdraw receipt."
  @type receipt_url :: String.t() | nil

  @typedoc "The method used for the withdraw. Currently, only `:pix` is supported."
  @type method :: :pix

  @typedoc """
  The type of Pix key used for the withdraw.

  - `:cpf` - CPF
  - `:cnpj` - CNPJ
  - `:phone` - PHONE
  - `:email` - EMAIL
  - `:random` - RANDOM
  - `:br_code` - BR_CODE
  """
  @type pix_type :: :cpf | :cnpj | :phone | :email | :random | :br_code

  @typedoc """
  The Pix information for the withdraw.

  - `:key` - The Pix key (string)
  - `:type` - The Pix key type. One of:
    - `:cpf` - CPF
    - `:cnpj` - CNPJ
    - `:phone` - PHONE
    - `:email` - EMAIL
    - `:random` - RANDOM
    - `:br_code` - BR_CODE
  """
  @type pix :: %{key: String.t(), type: pix_type} | nil

  @typedoc "The type of withdraw. Currently, only `:withdraw` is supported."
  @type kind :: :withdraw

  @typedoc "The amount withdrawn in cents."
  @type amount :: non_neg_integer()

  @typedoc "The platform fee for the withdraw in cents."
  @type platform_fee :: non_neg_integer()

  @typedoc "The external identifier associated with the withdraw."
  @type external_id :: String.t() | nil

  @typedoc "Timestamp when the withdraw was created."
  @type created_at :: String.t()

  @typedoc "Timestamp when the withdraw was last updated."
  @type updated_at :: String.t()

  @type t :: %__MODULE__{
          id: id,
          status: status,
          dev_mode: dev_mode,
          receipt_url: receipt_url,
          method: method,
          pix: pix,
          kind: kind,
          amount: amount,
          platform_fee: platform_fee,
          external_id: external_id,
          created_at: created_at,
          updated_at: updated_at
        }

  @doc """
  Creates a withdraw in AbacatePay.

  The `pix` param must be a map with:
    - `:key` (string): The Pix key
    - `:type` (atom): One of `:cpf`, `:cnpj`, `:phone`, `:email`, `:random`, `:br_code`

  ## Example

      AbacatePay.Withdraw.create(%AbacatePay.Withdraw{
        external_id: "withdraw-1234",
        method: :pix,
        amount: 10000,
        pix: %{key: "12345678900", type: :cpf},
        description: "Withdraw to CPF"
      })
  """
  @spec create(t()) :: {:ok, t()} | {:error, any()}
  def create(%__MODULE__{
        external_id: external_id,
        method: method,
        amount: amount,
        pix: pix,
        description: description
      }) do
    parsed_pix =
      case pix do
        %{key: key, type: type} when is_binary(key) and is_atom(type) ->
          %{
            key: key,
            type: type |> Atom.to_string() |> String.upcase()
          }

        _ ->
          nil
      end

    body =
      %{
        externalId: external_id,
        method: method |> Atom.to_string() |> String.upcase(),
        amount: amount,
        pix: parsed_pix,
        description: description
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    case Api.Withdraw.create_withdraw(body) do
      {:ok, data} ->
        build_pretty_withdraw(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Retrieves a withdraw by its external ID.

  ## Examples

      iex> withdraw = %AbacatePay.Withdraw{external_id: "withdraw-1234"}
      iex> AbacatePay.Withdraw.get(withdraw)
      {:ok, %AbacatePay.Withdraw{...}}
  """
  @spec get(withdraw :: t()) :: {:ok, t()} | {:error, any()}
  def get(%__MODULE__{external_id: external_id}) do
    case Api.Withdraw.get_withdraw(external_id) do
      {:ok, data} ->
        build_pretty_withdraw(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Lists all withdraws.

  ## Examples

      iex> AbacatePay.Withdraw.list()
      [
        %AbacatePay.Withdraw{...},
        %AbacatePay.Withdraw{...}
      ]
  """
  @spec list() :: {:ok, list(t())} | {:error, any()}
  def list do
    case Api.Withdraw.list_withdraws() do
      {:ok, data_list} ->
        data_list
        |> Enum.map(&build_pretty_withdraw/1)
        |> Enum.map(fn {:ok, withdraw} -> withdraw end)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Builds a pretty Withdraw struct from raw API data.

  ## Examples

      iex> raw_data = %{
      ...>   "id" => "tran_1234567890abcdef",
      ...>   "status" => "PENDING",
      ...>   "devMode" => false,
      ...>   "receiptUrl" => "https://abacatepay.com/receipt/tran_1234567890abcdef",
      ...>   "kind" => "WITHDRAW",
      ...>   "amount" => 10000,
      ...>   "platformFee" => 80,
      ...>   "externalId" => "withdraw-1234",
      ...>   "createdAt" => "2026-01-01T00:00:00Z",
      ...>   "updatedAt" => "2026-01-02T00:00:00Z"
      ...> }
      iex> AbacatePay.Withdraw.build_pretty_withdraw(raw_data)
      {:ok,
       %AbacatePay.Withdraw{
         id: "tran_1234567890abcdef",
         status: :pending,
         dev_mode: false,
         receipt_url: "https://abacatepay.com/receipt/tran_1234567890abcdef",
         kind: :withdraw,
         amount: 10000,
         platform_fee: 80,
         external_id: "withdraw-1234",
         created_at: "2026-01-01T00:00:00Z",
         updated_at: "2026-01-02T00:00:00Z"
       }}
  """
  @spec build_pretty_withdraw(raw_data :: map()) :: {:ok, t()}
  def build_pretty_withdraw(raw_data) do
    pretty_fields = %AbacatePay.Withdraw{
      id: Map.get(raw_data, "id"),
      status:
        Map.get(raw_data, "status")
        |> Macro.underscore()
        |> String.to_existing_atom(),
      description: Map.get(raw_data, "description"),
      dev_mode: Map.get(raw_data, "devMode"),
      receipt_url: Map.get(raw_data, "receiptUrl"),
      # Currently, only :pix is supported, so we set it directly
      method: :pix,
      kind:
        Map.get(raw_data, "kind")
        |> Macro.underscore()
        |> String.to_existing_atom(),
      amount: Map.get(raw_data, "amount"),
      platform_fee: Map.get(raw_data, "platformFee"),
      external_id: Map.get(raw_data, "externalId"),
      created_at: Map.get(raw_data, "createdAt"),
      pix:
        Map.get(raw_data, "pix")
        |> Map.update("key", nil, fn key_type ->
          key_type |> Macro.underscore() |> String.to_existing_atom()
        end),
      updated_at: Map.get(raw_data, "updatedAt")
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds a map suitable for the API from a `AbacatePay.Withdraw` struct

  ## Examples

      iex> withdraw = %AbacatePay.Withdraw{
      ...>   id: "tran_1234567890abcdef",
      ...>   status: :pending,
      ...>   dev_mode: false,
      ...>   receipt_url: "https://abacatepay.com/receipt/tran_1234567890abcdef",
      ...>   kind: :withdraw,
      ...>   amount: 10000,
      ...>   platform_fee: 80,
      ...>   external_id: "withdraw-1234",
      ...>   created_at: "2026-01-01T00:00:00Z",
      ...>   updated_at: "2026-01-02T00:00:00Z"
      ...> }
      iex> AbacatePay.Withdraw.build_api_withdraw(withdraw)
      {:ok,
       %{
         id: "tran_1234567890abcdef",
         status: "PENDING",
         devMode: false,
         receiptUrl: "https://abacatepay.com/receipt/tran_1234567890abcdef",
         kind: "WITHDRAW",
         amount: 10000,
         platformFee: 80,
         externalId: "withdraw-1234",
         createdAt: "2026-01-01T00:00:00Z",
         updatedAt: "2026-01-02T00:00:00Z"
       }}
  """
  @spec build_api_withdraw(pretty_withdraw :: t()) :: {:ok, map()}
  def build_api_withdraw(pretty_withdraw) do
    api_fields = %{
      id: pretty_withdraw.id,
      status:
        pretty_withdraw.status
        |> Atom.to_string()
        |> String.upcase(),
      devMode: pretty_withdraw.dev_mode,
      receiptUrl: pretty_withdraw.receipt_url,
      kind:
        pretty_withdraw.kind
        |> Atom.to_string()
        |> String.upcase(),
      amount: pretty_withdraw.amount,
      platformFee: pretty_withdraw.platform_fee,
      externalId: pretty_withdraw.external_id,
      createdAt: pretty_withdraw.created_at,
      updatedAt: pretty_withdraw.updated_at
    }

    {:ok, api_fields}
  end
end
