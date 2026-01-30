defmodule Abacatepay.Types.Billing do
  alias Abacatepay.Types.Product
  alias Abacatepay.Types.Customer

  @type status :: :PENDING | :EXPIRED | :CANCELLED | :PAID | :REFUNDED
  @type method :: :PIX
  @type kind :: :ONE_TIME

  @type t :: %{
          id: String.t(),
          url: String.t(),
          amount: integer,
          devMode: boolean,
          status: status(),
          frequency: kind(),
          metadata: metadata(),
          publicId: String.t(),
          createdAt: DateTime.t(),
          updatedAt: DateTime.t(),
          methods: list(method()),
          products: list(Product.t()),
          customer: Customer.t() | nil,
          customerId: Customer.id() | nil
        }

  @type metadata :: %{
          fee: integer,
          returnUrl: String.t(),
          completionUrl: String.t()
        }

  @type create_data :: %{
          frequency: kind(),
          metadata: metadata(),
          returnUrl: String.t(),
          methods: list(method()),
          completionUrl: String.t(),
          customer: Customer.t() | nil,
          customerId: Customer.id() | nil,
          products: list(Product.create_data())
        }

  @type response ::
          {:ok, t()}
          | {:error, String.t()}

  @type list_response ::
          {:ok, list(t())}
          | {:error, String.t()}
end
