defmodule AbacatePay.PaginationTest do
  use ExUnit.Case, async: true

  alias AbacatePay.Pagination

  describe "build_struct/1" do
    test "builds pagination struct from raw data" do
      raw = %{
        "page" => 2,
        "limit" => 20,
        "items" => 100,
        "totalPages" => 5
      }

      assert {:ok, %Pagination{} = pagination} = Pagination.build_struct(raw)
      assert pagination.page == 2
      assert pagination.limit == 20
      assert pagination.items == 100
      assert pagination.total_pages == 5
      assert pagination.has_next == nil
      assert pagination.has_previous == nil
      assert pagination.next_cursor == nil
    end

    test "builds cursor-based pagination struct from raw data" do
      raw = %{
        "hasNext" => true,
        "hasPrevious" => false,
        "limit" => 20,
        "nextCursor" => "cursor_123"
      }

      assert {:ok, %Pagination{} = pagination} = Pagination.build_struct(raw)
      assert pagination.page == nil
      assert pagination.items == nil
      assert pagination.total_pages == nil
      assert pagination.limit == 20
      assert pagination.has_next == true
      assert pagination.has_previous == false
      assert pagination.next_cursor == "cursor_123"
    end
  end

  describe "build_raw/1" do
    test "builds raw pagination data from pagination struct" do
      pagination = %Pagination{
        page: 1,
        limit: 10,
        items: 50,
        total_pages: 5,
        has_next: true,
        has_previous: false,
        next_cursor: "cursor_456"
      }

      assert {:ok, raw} = Pagination.build_raw(pagination)
      assert raw[:page] == 1
      assert raw[:limit] == 10
      assert raw[:items] == 50
      assert raw[:totalPages] == 5
      assert raw[:hasNext] == true
      assert raw[:hasPrevious] == false
      assert raw[:nextCursor] == "cursor_456"
    end
  end
end
