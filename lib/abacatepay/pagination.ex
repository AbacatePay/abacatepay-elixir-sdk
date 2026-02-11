defmodule AbacatePay.Pagination do
  @moduledoc ~S"""
  Struct representing pagination information in API responses.
  """

  defstruct [
    :page,
    :limit,
    :items,
    :total_pages,
    :has_next,
    :has_previous,
    :next_cursor
  ]

  @typedoc "Current page."
  @type page :: integer() | nil

  @typedoc "Number of items per page."
  @type limit :: integer() | nil

  @typedoc "Number of items."
  @type items :: integer() | nil

  @typedoc "Number of total pages."
  @type total_pages :: integer() | nil

  @typedoc "Indicates whether there is a next page."
  @type has_next :: boolean() | nil

  @typedoc "Indicates whether there is a previous page."
  @type has_previous :: boolean() | nil

  @typedoc "Cursor for the next page."
  @type next_cursor :: String.t() | nil

  @typedoc "A `AbacatePay.Pagination` that has a `pagination` field (Not cursor based)."
  @type pagination :: %__MODULE__{
          page: page,
          limit: limit,
          items: items,
          total_pages: total_pages,
          has_next: nil,
          has_previous: nil,
          next_cursor: nil
        }

  @typedoc "A `AbacatePay.Pagination` that has a `pagination` field and is cursor-based."
  @type cursor_based_pagination :: %__MODULE__{
          page: nil,
          limit: nil,
          items: nil,
          total_pages: nil,
          has_next: has_next,
          has_previous: has_previous,
          next_cursor: next_cursor
        }

  @type t :: pagination | cursor_based_pagination

  @doc """
  Builds a `AbacatePay.Pagination` struct from raw API response data.
  """
  @spec build_struct(raw_data :: map()) :: {:ok, t()}
  def build_struct(raw_data) do
    pretty_fields = %AbacatePay.Pagination{
      page: Map.get(raw_data, "page"),
      limit: Map.get(raw_data, "limit"),
      items: Map.get(raw_data, "items"),
      total_pages: Map.get(raw_data, "totalPages"),
      has_next: Map.get(raw_data, "hasNext"),
      has_previous: Map.get(raw_data, "hasPrevious"),
      next_cursor: Map.get(raw_data, "nextCursor")
    }

    {:ok, pretty_fields}
  end

  @doc """
  Builds raw pagination data from API response data.
  """
  @spec build_raw(pagination :: map()) :: {:ok, map()}
  def build_raw(pagination) do
    raw = %{
      page: pagination.page,
      limit: pagination.limit,
      items: pagination.items,
      totalPages: pagination.total_pages,
      hasNext: pagination.has_next,
      hasPrevious: pagination.has_previous,
      nextCursor: pagination.next_cursor
    }

    {:ok, raw}
  end
end
