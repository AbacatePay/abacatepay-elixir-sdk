defmodule AbacatePay.Billing do
  @moduledoc ~S"""
  Estrutura que representa uma cobrança na AbacatePay.
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

  @typedoc "Identificador único da cobrança."
  @type id :: String.t()

  @typedoc """
  Frequência da cobrança.

  - `:one_time` - Cobrança que aceita um único pagamento do mesmo cliente.
  - `:multiple_payments` - Cobrança em modo link de pagamento, aceita vários pagamentos de clientes diferentes.
  """
  @type frequency :: :one_time | :multiple_payments

  @typedoc "URL onde o usuário pode concluir o pagamento."
  @type url :: String.t()

  @typedoc """
  Status da cobrança.

  - `:pending` - 	A cobrança está com o pagamento pendente.
  - `:expired` - O tempo limite de pagamento foi excedido.
  - `:cancelled` - A cobrança foi cancelada por você.
  - `:paid` - 	A cobrança foi paga com sucesso pelo cliente.
  - `:refunded` - O valor foi devolvido ao cliente.
  """
  @type status :: :pending | :expired | :cancelled | :paid | :refunded

  @typedoc "Indica se a cobrança foi criada em ambiente de desenvolvimento."
  @type dev_mode :: boolean()

  @typedoc """
  Lista de métodos de pagamento disponíveis para esta cobrança.

  - `:pix` - Pagamento via Pix.
  - `:card` - Pagamento via cartão de débito.
  """
  @type methods :: [:pix | :card]

  @typedoc "Lista de produtos inclusos na cobrança."
  @type products :: [Product.t()]

  @typedoc "Cliente que você está cobrando. Opcional."
  @type customer :: Customer.t() | nil

  @typedoc """
  Objeto com metadados sobre a cobrança.

  - `:fee` - Taxa aplicada pela AbacatePay.
  - `:return_url` - URL que o cliente será redirecionado ao clicar no botão “voltar”.
  - `:completion_url` - URL que o cliente será redirecionado ao realizar o pagamento.
  """
  @type metadata :: %{
          fee: integer(),
          return_url: String.t(),
          completion_url: String.t()
        }

  @typedoc "Data e hora da próxima cobrança."
  @type next_billing :: String.t() | nil

  @typedoc "Permite ou não cupons para a cobrança."
  @type allow_coupons :: boolean()

  @typedoc "Cupons permitidos para esta cobrança. Só são considerados os cupons se `allow_coupons` é verdadeiro."
  @type coupons :: [String.t()] | nil

  @typedoc "Data e hora da criação da cobrança."
  @type created_at :: String.t()

  @typedoc "Data e hora da última atualização da cobrança."
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
  Permite que você recupere uma lista de todas as cobranças criadas.

  ## Exemplos

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

  @doc false

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
end
