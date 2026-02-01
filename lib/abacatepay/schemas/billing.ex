defmodule AbacatePay.Schema.Billing do
  @moduledoc false

  @billing_frequencies [:one_time, :multiple_payments]
  @billing_methods [:pix, :card]

  def create_billing_request,
    do: [
      frequency: [
        type: {:in, @billing_frequencies},
        required: true,
        doc: "available frequencies: #{Enum.map_join(@billing_frequencies, ", ", &to_string/1)}"
      ],
      methods: [
        type: {:list, {:in, @billing_methods}},
        required: true,
        doc: "available methods: #{Enum.map_join(@billing_methods, ", ", &to_string/1)}"
      ],
      products: [
        type: {:list, {:struct, AbacatePay.Product}},
        required: true
      ],
      return_url: [type: :string, required: true],
      completion_url: [type: :string, required: true],
      customer: [type: {:struct, AbacatePay.Customer}, required: false],
      allow_coupons: [type: :boolean, required: false],
      coupons: [type: {:list, :string}, required: false],
      external_id: [type: :string, required: false],
      metadata: [type: :map, required: false]
    ]
end
