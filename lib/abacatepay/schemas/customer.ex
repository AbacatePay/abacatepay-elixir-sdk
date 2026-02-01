defmodule AbacatePay.Schema.Customer do
  @moduledoc false

  def create_customer_request,
    do: [
      name: [type: :string, required: true],
      cellphone: [type: :string, required: true],
      email: [type: :string, required: true],
      tax_id: [type: :string, required: true]
    ]
end
