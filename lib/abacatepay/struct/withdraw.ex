defmodule AbacatePay.Withdraw do
  @moduledoc ~S"""
  Module that represents a withdraw in AbacatePay.
  """

  defstruct [
    :id,
    :status,
    :description,
    :dev_mode,
    :receipt_url,
    :kind,
    :amount,
    :platform_fee,
    :external_id,
    :created_at,
    :updated_at
  ]

  @typedoc "Unique ID of the AbacatePay withdrawal transaction."
  @type id :: String.t()

  @typedoc """
  Current status of the withdrawal transaction.

  - `:pending` - The withdraw is pending processing.
  - `:expired` - The withdraw request has expired.
  - `:cancelled` - The withdraw has been cancelled.
  - `:complete` - The withdraw has been completed successfully.
  - `:refunded` - The withdraw has been refunded.
  """
  @type status :: :pending | :expired | :cancelled | :complete | :refunded

  @typedoc "A description of the withdraw."
  @type description :: String.t() | nil

  @typedoc "Indicates whether the loot was created in a development environment (sandbox) or production. AbacatePay currently only supports withdrawals in production."
  @type dev_mode :: boolean()

  @typedoc "Withdrawal transaction receipt URL."
  @type receipt_url :: String.t() | nil

  @typedoc "Transaction type. It will always be `:withdraw`"
  @type kind :: :withdraw

  @typedoc "Withdrawal value in cents."
  @type amount :: non_neg_integer()

  @typedoc "Platform fee charged for withdrawal in cents."
  @type platform_fee :: non_neg_integer()

  @typedoc "Unique identifier of the withdrawal in your system. Optional."
  @type external_id :: String.t() | nil

  @typedoc "Date and time of withdrawal creation."
  @type created_at :: String.t()

  @typedoc "Date and time of last withdrawal update."
  @type updated_at :: String.t()

  @type t :: %__MODULE__{
          id: id,
          status: status,
          dev_mode: dev_mode,
          receipt_url: receipt_url,
          kind: kind,
          amount: amount,
          platform_fee: platform_fee,
          external_id: external_id,
          created_at: created_at,
          updated_at: updated_at
        }

  @doc """
  Creates a withdraw in AbacatePay.

  ## Example
      AbacatePay.Withdraw.create([
        external_id: "withdraw-1234",
        method: :pix,
        amount: 10000,
        pix: %{
          key: "123.456.789-01",
          type: :cpf
        },
        description: "Withdrawal for order #1234"
      ])

  Options: \n#{NimbleOptions.docs(AbacatePay.Schema.Withdraw.create_withdraw_request())}
  """

  def create(filter) do
    {:ok, options} =
      NimbleOptions.validate(filter, AbacatePay.Schema.Withdraw.create_withdraw_request())

    parsed_pix = %{
      key: options[:pix][:key],
      type: AbacatePay.Util.normalize_atom(options[:pix][:type])
    }

    body =
      %{
        externalId: options[:external_id],
        method: AbacatePay.Util.normalize_atom(options[:method]),
        amount: options[:amount],
        pix: parsed_pix,
        description: options[:description]
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    case AbacatePay.Api.Withdraw.create_withdraw(body) do
      {:ok, response} -> build_pretty_withdraw(response)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Retrieves a withdraw by its external ID.

  ## Examples
      iex> AbacatePay.Withdraw.get("withdraw-1234")
      {:ok, %AbacatePay.Withdraw{...}}
  """
  @spec get(external_id :: String.t()) :: {:ok, t()} | {:error, any()}
  def get(external_id) do
    case AbacatePay.Api.Withdraw.get_withdraw(external_id) do
      {:ok, response} -> build_pretty_withdraw(response)
      {:error, reason} -> {:error, reason}
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
    case AbacatePay.Api.Withdraw.list_withdraws() do
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
         created_at: ~U[2026-01-01T00:00:00Z],
         updated_at: ~U[2026-01-02T00:00:00Z]
       }}
  """
  @spec build_pretty_withdraw(raw_data :: map()) :: {:ok, t()}
  def build_pretty_withdraw(raw_data) do
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

    pretty_fields = %AbacatePay.Withdraw{
      id: raw_data["id"],
      status: AbacatePay.Util.atomize_enum(raw_data["status"]),
      description: raw_data["description"],
      dev_mode: raw_data["devMode"],
      receipt_url: raw_data["receiptUrl"],
      kind: AbacatePay.Util.atomize_enum(raw_data["kind"]),
      amount: raw_data["amount"],
      platform_fee: raw_data["platformFee"],
      external_id: raw_data["externalId"],
      created_at: created_at,
      updated_at: updated_at
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
    created_at =
      case pretty_withdraw.created_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    updated_at =
      case pretty_withdraw.updated_at do
        nil -> nil
        datetime -> DateTime.to_iso8601(datetime)
      end

    api_fields = %{
      id: pretty_withdraw.id,
      status: AbacatePay.Util.normalize_atom(pretty_withdraw.status),
      devMode: pretty_withdraw.dev_mode,
      receiptUrl: pretty_withdraw.receipt_url,
      kind: AbacatePay.Util.normalize_atom(pretty_withdraw.kind),
      amount: pretty_withdraw.amount,
      platformFee: pretty_withdraw.platform_fee,
      externalId: pretty_withdraw.external_id,
      createdAt: created_at,
      updatedAt: updated_at
    }

    {:ok, api_fields}
  end
end
