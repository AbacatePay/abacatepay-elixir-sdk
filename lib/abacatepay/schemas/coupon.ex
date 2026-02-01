defmodule AbacatePay.Schema.Coupon do
  @moduledoc false

  @discount_kinds [:percentage, :fixed]

  def create_coupon_request,
    do: [
      code: [type: :string, required: true],
      discount_kind: [
        type: {:in, @discount_kinds},
        required: true,
        doc: "available kinds: #{Enum.map_join(@discount_kinds, ", ", &to_string/1)}"
      ],
      discount: [type: :integer, required: true],
      notes: [type: :string, required: false],
      max_redeems: [type: :integer, required: false],
      metadata: [type: :map, required: false]
    ]
end
