defmodule AbacatePay.Api.PixTest do
  use ExUnit.Case
  use Mimic

  alias AbacatePay.Api.Pix
  alias AbacatePay.MockHTTPServer

  @default_pix_id "pix_char_123456"

  describe "create/1" do
    test "creates a qr code successfully with required fields" do
      body = %{
        amount: 4_000
      }

      expected_response = %{
        "id" => @default_pix_id,
        "amount" => 4_000,
        "status" => "PENDING",
        "devMode" => false,
        "brCode" => "00020101021226950014br.gov.bcb.pix",
        "brCodeBase64" => "data:image/png;base64,iVBORw0KGgoAAA",
        "platformFee" => 80,
        "createdAt" => "2025-03-24T21:50:20.772Z",
        "updatedAt" => "2025-03-24T21:50:20.772Z",
        "expiresAt" => "2025-03-25T21:50:20.772Z"
      }

      MockHTTPServer.stub_post("/pixQrCode/create", body, expected_response)

      assert {:ok, pix} = Pix.create(body)
      assert pix["id"] == @default_pix_id
      assert pix["amount"] == 4_000
      assert pix["status"] == "PENDING"
      assert pix["devMode"] == false
      assert pix["brCode"] == "00020101021226950014br.gov.bcb.pix"
      assert pix["brCodeBase64"] == "data:image/png;base64,iVBORw0KGgoAAA"
      assert pix["platformFee"] == 80
      assert pix["createdAt"] == "2025-03-24T21:50:20.772Z"
      assert pix["updatedAt"] == "2025-03-24T21:50:20.772Z"
      assert pix["expiresAt"] == "2025-03-25T21:50:20.772Z"
    end

    test "creates a qr code with all optional fields" do
      body = %{
        amount: 4_000,
        expires_in: 3_600,
        description: "Pagamento do pedido #12345",
        customer: %{
          name: "Daniel Lima",
          email: "daniel_lima@abacatepay.com",
          cellphone: "(11) 4002-8922",
          taxId: "123.456.789-01"
        },
        metadata: %{
          externalId: "order_12345"
        }
      }

      expected_response = %{
        "id" => @default_pix_id,
        "amount" => 4_000,
        "status" => "PENDING",
        "devMode" => false,
        "brCode" => "00020101021226950014br.gov.bcb.pix",
        "brCodeBase64" => "data:image/png;base64,iVBORw0KGgoAAA",
        "platformFee" => 80,
        "createdAt" => "2025-03-24T21:50:20.772Z",
        "updatedAt" => "2025-03-24T21:50:20.772Z",
        "expiresAt" => "2025-03-25T21:50:20.772Z"
      }

      MockHTTPServer.stub_post("/pixQrCode/create", body, expected_response)

      assert {:ok, pix} = Pix.create(body)
      assert pix["id"] == @default_pix_id
      assert pix["amount"] == 4_000
      assert pix["status"] == "PENDING"
      assert pix["devMode"] == false
      assert pix["brCode"] == "00020101021226950014br.gov.bcb.pix"
      assert pix["brCodeBase64"] == "data:image/png;base64,iVBORw0KGgoAAA"
      assert pix["platformFee"] == 80
      assert pix["createdAt"] == "2025-03-24T21:50:20.772Z"
      assert pix["updatedAt"] == "2025-03-24T21:50:20.772Z"
      assert pix["expiresAt"] == "2025-03-25T21:50:20.772Z"
    end

    test "creates a pix QR code with minimum amount" do
      body = %{
        amount: 100,
        description: "Minimum amount test"
      }

      expected_response = %{
        "id" => "pix_minimum",
        "qrCode" => "00020126...",
        "amount" => 100,
        "status" => "PENDING"
      }

      MockHTTPServer.stub_post("/pixQrCode/create", body, expected_response)

      assert {:ok, pix} = Pix.create(body)
      assert pix["amount"] == 100
      assert pix["id"] == "pix_minimum"
      assert pix["status"] == "PENDING"
    end

    test "creates a pix QR code with large amount" do
      body = %{
        amount: 99_999_999,
        description: "Large amount test"
      }

      expected_response = %{
        "id" => "pix_large",
        "qrCode" => "00020126...",
        "amount" => 99_999_999,
        "status" => "PENDING"
      }

      MockHTTPServer.stub_post("/pixQrCode/create", body, expected_response)

      assert {:ok, pix} = Pix.create(body)
      assert pix["amount"] == 99_999_999
      assert pix["id"] == "pix_large"
      assert pix["status"] == "PENDING"
    end

    test "handles missing required field - amount" do
      body = %{
        description: "Missing amount"
      }

      error = MockHTTPServer.mock_error(400, "Missing required field: amount")
      MockHTTPServer.stub_error(:post, "/pixQrCode/create", error)

      assert {:error, returned_error} = Pix.create(body)
      assert returned_error.status_code == 400
    end

    test "handles invalid amount" do
      body = %{
        amount: -1000,
        description: "Invalid amount"
      }

      error = MockHTTPServer.mock_error(422, "Amount must be positive")
      MockHTTPServer.stub_error(:post, "/pixQrCode/create", error)

      assert {:error, returned_error} = Pix.create(body)
      assert returned_error.status_code == 422
    end

    test "handles unauthorized error" do
      body = %{
        amount: 10_000,
        description: "Test"
      }

      error = MockHTTPServer.mock_error(401, "Unauthorized")
      MockHTTPServer.stub_error(:post, "/pixQrCode/create", error)

      assert {:error, returned_error} = Pix.create(body)
      assert returned_error.status_code == 401
    end

    test "handles server error" do
      body = %{
        amount: 15_000,
        description: "Server error test"
      }

      error = MockHTTPServer.mock_error(500, "Internal Server Error")
      MockHTTPServer.stub_error(:post, "/pixQrCode/create", error)

      assert {:error, returned_error} = Pix.create(body)
      assert returned_error.status_code == 500
    end
  end

  describe "simulate_payment/2" do
    test "simulates a payment successfully" do
      pix_id = @default_pix_id

      body = %{}

      expected_response = %{
        "id" => pix_id,
        "status" => "PAID",
        "amount" => 15_000
      }

      query = URI.encode_query(%{"id" => pix_id})
      MockHTTPServer.stub_post("/pixQrCode/simulate-payment?" <> query, body, expected_response)

      assert {:ok, result} = Pix.simulate_payment(pix_id, body)
      assert result["id"] == pix_id
      assert result["status"] == "PAID"
      assert result["amount"] == 15_000
    end

    test "simulates a payment with additional data" do
      pix_id = @default_pix_id

      body = %{
        amount: 25_000
      }

      expected_response = %{
        "id" => pix_id,
        "status" => "PAID",
        "amount" => 25_000,
        "fee" => 80
      }

      query = URI.encode_query(%{"id" => pix_id})
      MockHTTPServer.stub_post("/pixQrCode/simulate-payment?" <> query, body, expected_response)

      assert {:ok, result} = Pix.simulate_payment(pix_id, body)
      assert result["fee"] == 80
      assert result["amount"] == 25_000
    end

    test "handles pix not found error" do
      pix_id = "pix_invalid"

      body = %{}
      error = MockHTTPServer.mock_error(404, "Pix QR Code not found")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:post, "/pixQrCode/simulate-payment?" <> query, error)

      assert {:error, returned_error} = Pix.simulate_payment(pix_id, body)
      assert returned_error.status_code == 404
    end

    test "handles pix already paid error" do
      pix_id = "pix_already_paid"

      body = %{}
      error = MockHTTPServer.mock_error(409, "Pix QR Code already paid")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:post, "/pixQrCode/simulate-payment?" <> query, error)

      assert {:error, returned_error} = Pix.simulate_payment(pix_id, body)
      assert returned_error.status_code == 409
    end

    test "handles pix expired error" do
      pix_id = "pix_expired"

      body = %{}
      error = MockHTTPServer.mock_error(400, "Pix QR Code has expired")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:post, "/pixQrCode/simulate-payment?" <> query, error)

      assert {:error, returned_error} = Pix.simulate_payment(pix_id, body)
      assert returned_error.status_code == 400
    end

    test "handles unauthorized error" do
      pix_id = "pix_test"

      body = %{}
      error = MockHTTPServer.mock_error(401, "Unauthorized")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:post, "/pixQrCode/simulate-payment?" <> query, error)

      assert {:error, returned_error} = Pix.simulate_payment(pix_id, body)
      assert returned_error.status_code == 401
    end

    test "simulates payment with special characters in ID" do
      pix_id = "pix_char_mXTWdj6sABWnc4uL2Rh1r6tb"
      body = %{}

      expected_response = %{
        "id" => pix_id,
        "status" => "PAID"
      }

      query = URI.encode_query(%{"id" => pix_id})
      MockHTTPServer.stub_post("/pixQrCode/simulate-payment?" <> query, body, expected_response)

      assert {:ok, result} = Pix.simulate_payment(pix_id, body)
      assert result["id"] == pix_id
    end
  end

  describe "check_status/1" do
    test "checks pix QR code status successfully" do
      pix_id = "pix_xyz789"

      expected_response = %{
        "id" => pix_id,
        "status" => "PENDING",
        "amount" => 15_000,
        "expiresAt" => "2026-02-02T13:00:00Z",
        "createdAt" => "2026-02-02T10:00:00Z"
      }

      query = URI.encode_query(%{"id" => pix_id})
      MockHTTPServer.stub_get("/pixQrCode/check?" <> query, expected_response)

      assert {:ok, pix} = Pix.check_status(pix_id)
      assert pix["id"] == pix_id
      assert pix["status"] == "PENDING"
    end

    test "returns not found error when checking invalid pix" do
      pix_id = "pix_invalid"

      error = MockHTTPServer.mock_error(404, "Pix QR Code not found")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:get, "/pixQrCode/check?" <> query, error)

      assert {:error, returned_error} = Pix.check_status(pix_id)
      assert returned_error.status_code == 404
    end

    test "handles unauthorized error" do
      pix_id = "pix_test"

      error = MockHTTPServer.mock_error(401, "Unauthorized")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:get, "/pixQrCode/check?" <> query, error)

      assert {:error, returned_error} = Pix.check_status(pix_id)
      assert returned_error.status_code == 401
    end

    test "handles server error" do
      pix_id = "pix_error"

      error = MockHTTPServer.mock_error(500, "Internal Server Error")
      query = URI.encode_query(%{"id" => pix_id})

      MockHTTPServer.stub_error(:get, "/pixQrCode/check?" <> query, error)

      assert {:error, returned_error} = Pix.check_status(pix_id)
      assert returned_error.status_code == 500
    end

    test "checks status with special characters in ID" do
      pix_id = "pix_char_mXTWdj6sABWnc4uL2Rh1r6tb"

      expected_response = %{
        "id" => pix_id,
        "status" => "PENDING"
      }

      query = URI.encode_query(%{"id" => pix_id})
      MockHTTPServer.stub_get("/pixQrCode/check?" <> query, expected_response)

      assert {:ok, pix} = Pix.check_status(pix_id)
      assert pix["id"] == pix_id
    end
  end
end
