defmodule AbacatePay.Schema.Pix do
  @moduledoc false

  def create_pix_request,
    do: [
      amount: [type: :integer, required: true],
      description: [type: :string, required: false],
      customer: [type: {:struct, AbacatePay.Customer}, required: false],
      expires_in: [type: :integer, required: false],
      metadata: [type: :map, required: false]
    ]
end
