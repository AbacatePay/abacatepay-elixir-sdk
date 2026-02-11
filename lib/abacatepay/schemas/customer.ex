defmodule AbacatePay.Schema.Customer do
  @moduledoc false

  def create_customer_request,
    do: [
      name: [type: :string, required: true],
      cellphone: [type: :string, required: true],
      email: [type: :string, required: true],
      tax_id: [type: :string, required: true],
      zip_code: [type: :string, required: false],
      metadata: [type: :map, required: false]
    ]

  def list_customers_request,
    do: [
      page: [type: :integer, default: 1, required: false],
      limit: [type: :integer, default: 20, required: false]
    ]
end
