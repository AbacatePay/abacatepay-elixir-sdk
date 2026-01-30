defmodule Abacatepay.Types.Product do
  @type t :: %{
          quantity: integer,
          productId: String.t()
        }

  @type create_data :: %{
          price: float,
          name: String.t(),
          quantity: integer,
          externalId: String.t(),
          description: String.t() | nil
        }
end
