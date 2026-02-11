defmodule AbacatePay.PixTest do
  use ExUnit.Case

  alias AbacatePay.{Pix, Util}

  describe "struct/0" do
    test "creates a valid Pix struct" do
      pix = %Pix{
        id: "pix_123",
        amount: 15_000,
        status: :pending,
        dev_mode: false,
        br_code: "test_code",
        br_code_base_64: "data:image/png;base64,test",
        platform_fee: 80
      }

      assert pix.id == "pix_123"
      assert pix.amount == 15_000
      assert pix.status == :pending
    end

    test "creates Pix with nil values" do
      pix = %Pix{}

      assert pix.id == nil
      assert pix.amount == nil
      assert pix.status == nil
    end
  end

  describe "build_pretty_pix_qrcode/1" do
    test "builds Pix from raw API data" do
      raw_data = %{
        "id" => "pix_charabc123456789",
        "amount" => 1_500,
        "status" => "PAID",
        "devMode" => false,
        "brCode" => "00020126360014BR.GOV.BCB.PIX",
        "brCodeBase64" => "data:image/png;base64,test",
        "platformFee" => 80,
        "createdAt" => "2026-01-01T12:00:00Z",
        "updatedAt" => "2026-01-01T12:05:00Z",
        "expiresAt" => "2026-01-02T12:00:00Z",
        "expiresIn" => nil
      }

      assert {:ok, pix} = Pix.build_struct(raw_data)
      assert pix.id == "pix_charabc123456789"
      assert pix.amount == 1_500
      assert pix.status == :paid
      assert pix.dev_mode == false
      assert pix.br_code == "00020126360014BR.GOV.BCB.PIX"
      assert pix.platform_fee == 80
    end

    test "handles datetime parsing" do
      raw_data = %{
        "id" => "pix_123",
        "amount" => 1_000,
        "status" => "PENDING",
        "devMode" => false,
        "brCode" => "code",
        "brCodeBase64" => "data",
        "platformFee" => 0,
        "createdAt" => "2026-01-15T10:30:45Z",
        "updatedAt" => "2026-01-15T10:35:45Z",
        "expiresAt" => "2026-01-16T10:30:45Z",
        "expiresIn" => nil
      }

      assert {:ok, pix} = Pix.build_struct(raw_data)
      assert pix.created_at != nil
      assert pix.updated_at != nil
      assert pix.expires_at != nil
    end

    test "handles nil datetimes" do
      raw_data = %{
        "id" => "pix_123",
        "amount" => 1_000,
        "status" => "PENDING",
        "devMode" => false,
        "brCode" => "code",
        "brCodeBase64" => "data",
        "platformFee" => 0,
        "createdAt" => nil,
        "updatedAt" => nil,
        "expiresAt" => nil,
        "expiresIn" => nil
      }

      assert {:ok, pix} = Pix.build_struct(raw_data)
      assert pix.created_at == nil
      assert pix.updated_at == nil
      assert pix.expires_at == nil
    end

    test "handles various pix statuses" do
      statuses = ["PENDING", "PAID", "EXPIRED", "CANCELLED", "REFUNDED"]

      Enum.each(statuses, fn status ->
        raw_data = %{
          "id" => "pix_#{status}",
          "amount" => 1_000,
          "status" => status,
          "devMode" => false,
          "brCode" => "code",
          "brCodeBase64" => "data",
          "platformFee" => 0,
          "createdAt" => nil,
          "updatedAt" => nil,
          "expiresAt" => nil,
          "expiresIn" => nil
        }

        assert {:ok, pix} = Pix.build_struct(raw_data)
        assert pix.status == Util.atomize_enum(status)
      end)
    end

    test "handles large amounts" do
      raw_data = %{
        "id" => "pix_large",
        "amount" => 999_999_999,
        "status" => "PENDING",
        "devMode" => false,
        "brCode" => "code",
        "brCodeBase64" => "data",
        "platformFee" => 80_000,
        "createdAt" => nil,
        "updatedAt" => nil,
        "expiresAt" => nil,
        "expiresIn" => nil
      }

      assert {:ok, pix} = Pix.build_struct(raw_data)
      assert pix.amount == 999_999_999
      assert pix.platform_fee == 80_000
    end
  end

  describe "build_api_pix_qrcode/1" do
    test "builds API map from Pix struct" do
      pix = %Pix{
        id: "pix_123",
        amount: 1_500,
        status: :paid,
        dev_mode: false,
        br_code: "test_code",
        br_code_base_64: "data:image/png;base64,test",
        platform_fee: 80,
        created_at: ~U[2026-01-01T12:00:00Z],
        updated_at: ~U[2026-01-01T12:05:00Z],
        expires_at: ~U[2026-01-02T12:00:00Z]
      }

      assert {:ok, raw} = Pix.build_raw(pix)
      assert raw[:id] == "pix_123"
      assert raw[:amount] == 1_500
      assert raw[:status] == "PAID"
      assert raw[:devMode] == false
      assert String.contains?(raw[:createdAt], "2026-01-01")
    end

    test "handles nil datetimes in API format" do
      pix = %Pix{
        id: "pix_123",
        amount: 1_000,
        status: :pending,
        dev_mode: false,
        br_code: "code",
        br_code_base_64: "data",
        platform_fee: 0,
        created_at: nil,
        updated_at: nil,
        expires_at: nil
      }

      assert {:ok, raw} = Pix.build_raw(pix)
      assert raw[:createdAt] == nil
      assert raw[:updatedAt] == nil
      assert raw[:expiresAt] == nil
    end
  end

  describe "roundtrip conversion" do
    test "converts raw data to struct and back" do
      data = %{
        "id" => "pix_roundtrip",
        "amount" => 5_000,
        "status" => "PENDING",
        "devMode" => true,
        "brCode" => "00020126360014BR.GOV.BCB.PIX",
        "brCodeBase64" => "data:image/png;base64,test",
        "platformFee" => 80,
        "createdAt" => "2026-01-15T10:30:45Z",
        "updatedAt" => "2026-01-15T10:35:45Z",
        "expiresAt" => nil,
        "expiresIn" => nil
      }

      assert {:ok, pix} = Pix.build_struct(data)
      assert {:ok, raw} = Pix.build_raw(pix)

      assert raw[:id] == data["id"]
      assert raw[:amount] == data["amount"]
      assert raw[:status] == data["status"]
    end
  end
end
