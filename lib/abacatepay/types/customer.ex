defmodule Abacatepay.Types.Customer do
  @moduledoc """
  Customer-related type definitions that match the API structures.
  """

  @type metadata :: %{
          name: String.t(),
          taxId: String.t(),
          email: String.t(),
          cellphone: String.t()
        }

  @type id :: %{
          id: String.t(),
          devMode: boolean,
          storeId: String.t(),
          publicId: String.t(),
          metadata: metadata(),
          updatedAt: DateTime.t(),
          createdAt: DateTime.t()
        }

  @type t :: %{
          id: String.t(),
          metadata: metadata()
        }

  @type response ::
          {:ok, t()}
          | {:error, String.t()}

  @type list_response ::
          {:ok, list(t())}
          | {:error, String.t()}

  defstruct [:id, :metadata]
end
