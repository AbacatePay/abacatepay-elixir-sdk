defmodule AbacatePay.Api.CustomerTest do
  use ExUnit.Case, async: true
  use Mimic

  alias AbacatePay.Api.Customer
  alias AbacatePay.MockHTTPServer

  @default_customer_id "cust_aebxkhDZNaMmJeKsy0AHS0FQ"

  describe "create/1" do
    test "creates a customer successfully" do
      body = %{
        name: "Daniel Lima",
        cellphone: "(11) 4002-8922",
        email: "daniel_lima@abacatepay.com",
        taxId: "123.456.789-01",
        country: "BR",
        zipCode: "12345-678",
        metadata: %{"key" => "value"}
      }

      expected_response = %{
        "id" => @default_customer_id,
        "name" => "Daniel Lima",
        "cellphone" => "(11) 4002-8922",
        "email" => "daniel_lima@abacatepay.com",
        "taxId" => "123.456.789-01",
        "country" => "BR",
        "zipCode" => "12345-678",
        "devMode" => false,
        "metadata" => %{"key" => "value"}
      }

      MockHTTPServer.stub_post("/customers/create", body, expected_response)

      assert {:ok, customer} = Customer.create(body)
      assert customer["id"] == @default_customer_id
      assert customer["name"] == "Daniel Lima"
      assert customer["email"] == "daniel_lima@abacatepay.com"
      assert customer["cellphone"] == "(11) 4002-8922"
      assert customer["taxId"] == "123.456.789-01"
      assert customer["country"] == "BR"
      assert customer["zipCode"] == "12345-678"
      assert customer["devMode"] == false
    end

    test "handles error response when creating customer" do
      body = %{
        name: "Invalid Customer",
        email: "invalid-email"
      }

      error = MockHTTPServer.mock_error(422, "Invalid email format")
      MockHTTPServer.stub_error(:post, "/customers/create", error)

      assert {:error, returned_error} = Customer.create(body)
      assert returned_error.status_code == 422
    end
  end

  describe "get/1" do
    test "retrieves a customer successfully" do
      expected_response = %{
        "id" => @default_customer_id,
        "name" => "Daniel Lima",
        "cellphone" => "(11) 4002-8922",
        "email" => "daniel_lima@abacatepay.com",
        "taxId" => "123.456.789-01",
        "country" => "BR",
        "zipCode" => "12345-678",
        "devMode" => false,
        "metadata" => %{"key" => "value"}
      }

      MockHTTPServer.stub_get("/customers/get?id=#{@default_customer_id}", expected_response)
      assert {:ok, customer} = Customer.get(@default_customer_id)
      assert customer["id"] == @default_customer_id
      assert customer["name"] == "Daniel Lima"
      assert customer["email"] == "daniel_lima@abacatepay.com"
      assert customer["cellphone"] == "(11) 4002-8922"
      assert customer["taxId"] == "123.456.789-01"
      assert customer["country"] == "BR"
      assert customer["zipCode"] == "12345-678"
      assert customer["devMode"] == false
      assert customer["metadata"] == %{"key" => "value"}
    end

    test "handles error response when retrieving customer" do
      error = MockHTTPServer.mock_error(404, "Customer not found")
      MockHTTPServer.stub_error(:get, "/customers/get?id=#{@default_customer_id}", error)

      assert {:error, returned_error} = Customer.get(@default_customer_id)
      assert returned_error.status_code == 404
    end
  end

  describe "list/1" do
    test "lists all customers successfully" do
      expected_response = %{
        "data" => [
          %{
            "id" => @default_customer_id,
            "name" => "Daniel Lima",
            "cellphone" => "(11) 4002-8922",
            "email" => "daniel_lima@abacatepay.com",
            "taxId" => "123.456.789-01",
            "country" => "BR",
            "zipCode" => "12345-678",
            "devMode" => false,
            "metadata" => %{"key" => "value"}
          },
          %{
            "id" => "cust_bcdxkhDZNaMmJeKsy0AHS0FQ",
            "name" => "Customer 2",
            "email" => "customer2@example.com",
            "cellphone" => "(21) 3003-7788",
            "taxId" => "987.654.321-00",
            "country" => "BR",
            "zipCode" => "87654-321",
            "devMode" => true,
            "metadata" => %{"another_key" => "another_value"}
          }
        ],
        "pagination" => %{
          "page" => 1,
          "limit" => 20,
          "totalPages" => 5,
          "totalItems" => 100
        }
      }

      MockHTTPServer.stub_get("/customers/list?page=1&limit=20", expected_response)

      assert {:ok, customers, pagination} = Customer.list(%{page: 1, limit: 20})
      assert is_list(customers)
      assert length(customers) == 2
      assert Enum.all?(customers, &is_map/1)
      assert pagination["page"] == 1
      assert pagination["limit"] == 20
      assert pagination["totalPages"] == 5
      assert pagination["totalItems"] == 100
    end

    test "returns empty list when no customers exist" do
      expected_response = %{
        "data" => [],
        "pagination" => %{
          "page" => 1,
          "limit" => 20,
          "totalPages" => 0,
          "totalItems" => 0
        }
      }

      MockHTTPServer.stub_get("/customers/list?page=1&limit=20", expected_response)

      assert {:ok, customers, pagination} = Customer.list(%{page: 1, limit: 20})
      assert customers == []
      assert pagination["page"] == 1
      assert pagination["limit"] == 20
      assert pagination["totalPages"] == 0
      assert pagination["totalItems"] == 0
    end

    test "handles error response when listing customers" do
      error = MockHTTPServer.mock_error(401, "Token de autenticação inválido ou ausente.")
      MockHTTPServer.stub_error(:get, "/customers/list?page=1&limit=20", error)

      assert {:error, returned_error} = Customer.list(%{page: 1, limit: 20})
      assert returned_error.status_code == 401
    end
  end
end
