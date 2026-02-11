defmodule AbacatePay.HttpClientTest do
  use ExUnit.Case, async: true
  use Mimic

  alias AbacatePay.{HTTPClient, MockHTTPServer}

  describe "HTTPClient HTTP Methods" do
    test "get/1 returns parsed response data" do
      expected_data = [
        %{
          "id" => "bill_123456",
          "metadata" => %{
            "name" => "Daniel Lima",
            "cellphone" => "(11) 4002-8922",
            "email" => "daniel_lima@abacatepay.com",
            "taxId" => "123.456.789-01"
          }
        }
      ]

      MockHTTPServer.stub_get("/customers/list", expected_data)

      assert {:ok, data} = HTTPClient.get("/customers/list")
      assert data == expected_data
    end

    test "get/1 returns prased response data with pagination" do
      expected_data = %{
        "data" => [
          %{
            "id" => "bill_123456",
            "metadata" => %{
              "name" => "Daniel Lima",
              "cellphone" => "(11) 4002-8922",
              "email" => "daniel_lima@abacatepay.com",
              "taxId" => "123.456.789-01"
            }
          }
        ],
        "pagination" => %{
          "page" => 1,
          "limit" => 20,
          "totalPages" => 5,
          "totalItems" => 100
        }
      }

      MockHTTPServer.stub_get("/customers/list?page=1&limit=20", expected_data)
      assert {:ok, data, pagination} = HTTPClient.get("/customers/list?page=1&limit=20")

      assert data == expected_data["data"]
      assert pagination == expected_data["pagination"]
    end

    test "post/2 returns parsed response data" do
      body = %{
        name: "Daniel Lima",
        cellphone: "(11) 4002-8922",
        email: "daniel_lima@abacatepay.com",
        taxId: "123.456.789-01"
      }

      expected_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        "metadata" => %{
          "name" => "Daniel Lima",
          "cellphone" => "(11) 4002-8922",
          "email" => "daniel_lima@abacatepay.com",
          "taxId" => "123.456.789-01"
        }
      }

      MockHTTPServer.stub_post("/customers/create", body, expected_data)

      assert {:ok, data} = HTTPClient.post("/customers/create", body)
      assert data == expected_data
    end

    test "put/2 returns parsed response data" do
      body = %{name: "Nicolas Ribeiro"}

      expected_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        "metadata" => %{
          "name" => "Nicolas Ribeiro",
          "cellphone" => "(11) 4002-8922",
          "email" => "daniel_lima@abacatepay.com",
          "taxId" => "123.456.789-01"
        }
      }

      MockHTTPServer.stub_put(
        "/customers/cust_aebxkhDZNaMmJeKsy0AHS0FQ/update",
        body,
        expected_data
      )

      assert {:ok, data} = HTTPClient.put("/customers/cust_aebxkhDZNaMmJeKsy0AHS0FQ/update", body)
      assert data == expected_data
    end

    test "delete/1 returns parsed response data" do
      expected_data = nil
      MockHTTPServer.stub_delete("/customers/cust_aebxkhDZNaMmJeKsy0AHS0FQ/delete", expected_data)

      assert {:ok, _} = HTTPClient.delete("/customers/cust_aebxkhDZNaMmJeKsy0AHS0FQ/delete")
    end
  end

  describe "Error Handling" do
    test "get/1 returns error response" do
      error = MockHTTPServer.mock_error(404, "Not Found")
      MockHTTPServer.stub_error(:get, "/invalid", error)

      assert {:error, returned_error} = HTTPClient.get("/invalid")
      assert returned_error.status_code == 404
      assert returned_error.message == "Not Found"
    end

    test "post/2 returns error response" do
      body = %{"invalid" => "data"}
      error = MockHTTPServer.mock_error(422, "Invalid parameters")
      MockHTTPServer.stub_error(:post, "/customers/create", error)

      assert {:error, returned_error} = HTTPClient.post("/customers/create", body)
      assert returned_error.status_code == 422
    end

    test "put/2 returns error response" do
      body = %{"invalid" => "data"}
      error = MockHTTPServer.mock_error(422, "Invalid parameters")
      MockHTTPServer.stub_error(:put, "/customers/1/update", error)

      assert {:error, returned_error} = HTTPClient.put("/customers/1/update", body)
      assert returned_error.status_code == 422
    end

    test "delete/1 returns error response" do
      error = MockHTTPServer.mock_error(404, "Not Found")
      MockHTTPServer.stub_error(:delete, "/invalid", error)

      assert {:error, returned_error} = HTTPClient.delete("/invalid")
      assert returned_error.status_code == 404
    end
  end
end
