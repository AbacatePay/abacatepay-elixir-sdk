defmodule AbacatePay.Product do
  @moduledoc ~S"""
  Estrutura que representa um produto na AbacatePay.
  """

  defstruct [
    :external_id,
    :quantity,
    :price,
    :description,
    :name
  ]

  @typedoc "O id do produto em seu sistema. Utilizamos esse id para criar seu produto na AbacatePay de forma automática, então certifique-se de que seu id é único."
  @type external_id :: String.t()

  @typedoc "Quantidade do produto sendo adquirida."
  @type quantity :: non_neg_integer()

  @typedoc "Preço por unidade do produto em centavos. O mínimo é 100 (1 BRL)."
  @type price :: non_neg_integer()

  @typedoc "Descrição detalhada do produto."
  @type description :: String.t()

  @typedoc "Nome do produto."
  @type name :: String.t()

  @type t :: %__MODULE__{
          id: id,
          external_id: external_id,
          quantity: quantity,
          price: price,
          description: description,
          name: name
        }

  @doc false
  def build_pretty_product(raw_data) do
    pretty_fields = %AbacatePay.Product{
      id: Map.get(raw_data, "id"),
      external_id: Map.get(raw_data, "externalId"),
      quantity: Map.get(raw_data, "quantity"),
      price: Map.get(raw_data, "price"),
      description: Map.get(raw_data, "description"),
      name: Map.get(raw_data, "name")
    }

    {:ok, pretty_fields}
  end
end
