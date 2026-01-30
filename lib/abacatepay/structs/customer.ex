defmodule AbacatePay.Customer do
  alias AbacatePay.Api

  defstruct [
    :id,
    :metadata
  ]

  @type id :: String.t()

  @type metadata :: %{
          name: String.t() | nil,
          cellphone: String.t() | nil,
          tax_id: String.t() | nil,
          email: String.t()
        }

  @type t :: %__MODULE__{
          id: id,
          metadata: metadata
        }

  def create(%__MODULE__{metadata: metadata}) do
    customer = build_api_customer(%__MODULE__{metadata: metadata})

    case Api.Customer.create_customer(customer) do
      {:ok, data} ->
        build_pretty_customer(data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def list() do
    case Api.Customer.list_customers() do
      {:ok, data_list} ->
        data_list
        |> Enum.map(&build_pretty_customer/1)
        |> Enum.map(fn {:ok, customer} -> customer end)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def build_api_customer(%__MODULE__{id: id, metadata: metadata}) do
    %{
      id: id,
      metadata: %{
        name: metadata.name,
        cellphone: metadata.cellphone,
        email: metadata.email,
        taxId: metadata.tax_id
      }
    }
  end

  @doc false
  def build_pretty_customer(raw_data) do
    pretty_fields = %AbacatePay.Customer{
      id: Map.get(raw_data, "id"),
      metadata: %{
        name: Map.get(raw_data, "name"),
        cellphone: Map.get(raw_data, "cellphone"),
        tax_id: Map.get(raw_data, "taxId"),
        email: Map.get(raw_data, "email")
      }
    }

    {:ok, pretty_fields}
  end
end
