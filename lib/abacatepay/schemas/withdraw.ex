defmodule AbacatePay.Schema.Withdraw do
  @moduledoc false

  @available_methods [:pix]
  @available_pix_types [:cpf, :cnpj, :phone, :email, :random, :br_code]

  @spec create_withdraw_request() :: keyword()
  def create_withdraw_request,
    do: [
      external_id: [type: :string, required: true],
      method: [
        type: {:in, @available_methods},
        required: true,
        doc: "available methods: #{Enum.map_join(@available_methods, ", ", &to_string/1)}"
      ],
      amount: [type: :integer, required: true],
      pix: [
        type: :map,
        required: true,
        keys: [
          key: [type: :string, required: true],
          type: [
            type: {:in, @available_pix_types},
            required: true,
            doc: "available types: #{Enum.map_join(@available_pix_types, ", ", &to_string/1)}"
          ]
        ]
      ],
      description: [type: :string, required: false]
    ]
end
