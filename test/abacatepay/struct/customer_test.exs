defmodule AbacatePay.CustomerTest do
  use ExUnit.Case

  alias AbacatePay.Customer

  describe "struct/0" do
    test "creates a valid Customer struct" do
      customer = %Customer{
        id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        name: "Daniel Lima",
        cellphone: "(11) 4002-8922",
        tax_id: "123.456.789-01",
        email: "daniel_lima@abacatepay.com",
        country: "BR",
        zip_code: "12345-678",
        metadata: %{key: "value"}
      }

      assert customer.id == "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      assert customer.name == "Daniel Lima"
      assert customer.cellphone == "(11) 4002-8922"
      assert customer.tax_id == "123.456.789-01"
      assert customer.email == "daniel_lima@abacatepay.com"
      assert customer.country == "BR"
      assert customer.zip_code == "12345-678"
      assert customer.metadata == %{key: "value"}
    end

    test "creates Customer with nil values" do
      customer = %Customer{}

      assert customer.id == nil
      assert customer.name == nil
      assert customer.cellphone == nil
      assert customer.tax_id == nil
      assert customer.email == nil
      assert customer.country == nil
      assert customer.zip_code == nil
      assert customer.metadata == nil
    end
  end

  describe "build_struct/1" do
    test "builds Customer from raw API data" do
      raw_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        "name" => "Daniel Lima",
        "cellphone" => "(11) 4002-8922",
        "taxId" => "123.456.789-01",
        "email" => "daniel_lima@abacatepay.com",
        "country" => "BR",
        "zipCode" => "12345-678",
        "metadata" => %{"key" => "value"}
      }

      assert {:ok, customer} = Customer.build_struct(raw_data)
      assert customer.id == "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      assert customer.name == "Daniel Lima"
      assert customer.cellphone == "(11) 4002-8922"
      assert customer.tax_id == "123.456.789-01"
      assert customer.email == "daniel_lima@abacatepay.com"
      assert customer.country == "BR"
      assert customer.zip_code == "12345-678"
      assert customer.metadata == %{key: "value"}
    end

    test "handles missing fields" do
      raw_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        "email" => "daniel_lima@abacatepay.com"
      }

      assert {:ok, customer} = Customer.build_struct(raw_data)
      assert customer.id == "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      assert customer.email == "daniel_lima@abacatepay.com"
      assert customer.name == nil
      assert customer.cellphone == nil
      assert customer.tax_id == nil
      assert customer.country == nil
      assert customer.zip_code == nil
      assert customer.metadata == nil
    end

    test "handles missing data entirely" do
      raw_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      }

      assert {:ok, customer} = Customer.build_struct(raw_data)
      assert customer.id == "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      assert customer.name == nil
      assert customer.cellphone == nil
      assert customer.tax_id == nil
      assert customer.email == nil
      assert customer.country == nil
      assert customer.zip_code == nil
      assert customer.metadata == nil
    end

    test "handles special characters in name" do
      raw_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        "name" => "José da Silva",
        "email" => "jose@example.com"
      }

      assert {:ok, customer} = Customer.build_struct(raw_data)
      assert customer.name == "José da Silva"
    end
  end

  describe "build_raw/1" do
    test "builds API map from Customer struct" do
      customer = %Customer{
        id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        name: "Daniel Lima",
        dev_mode: false,
        cellphone: "(11) 4002-8922",
        email: "daniel_lima@abacatepay.com",
        tax_id: "123.456.789-01",
        country: "BR",
        zip_code: "12345-678",
        metadata: %{key: "value"}
      }

      assert {:ok, api_map} = Customer.build_raw(customer)
      assert api_map[:id] == "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      assert api_map[:name] == "Daniel Lima"
      assert api_map[:devMode] == false
      assert api_map[:cellphone] == "(11) 4002-8922"
      assert api_map[:taxId] == "123.456.789-01"
      assert api_map[:email] == "daniel_lima@abacatepay.com"
      assert api_map[:country] == "BR"
      assert api_map[:zipCode] == "12345-678"
      assert api_map[:metadata] == %{"key" => "value"}
    end

    test "handles nil optional fields" do
      customer = %Customer{
        id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        email: "daniel_lima@abacatepay.com",
        dev_mode: false,
        name: nil,
        cellphone: nil,
        tax_id: nil,
        country: nil,
        zip_code: nil,
        metadata: nil
      }

      assert {:ok, api_map} = Customer.build_raw(customer)
      assert api_map[:id] == "cust_aebxkhDZNaMmJeKsy0AHS0FQ"
      assert api_map[:email] == "daniel_lima@abacatepay.com"
      assert api_map[:devMode] == false
      assert api_map[:name] == nil
      assert api_map[:cellphone] == nil
      assert api_map[:taxId] == nil
      assert api_map[:country] == nil
      assert api_map[:zipCode] == nil
      assert api_map[:metadata] == nil
    end

    test "preserves all fields" do
      customer = %Customer{
        id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        name: "Daniel Lima",
        dev_mode: false,
        cellphone: "(11) 4002-8922",
        tax_id: "123.456.789-01",
        email: "daniel_lima@abacatepay.com",
        country: "BR",
        zip_code: "12345-678",
        metadata: %{key: "value"}
      }

      assert {:ok, api_map} = Customer.build_raw(customer)
      assert map_size(api_map) == 9
      assert map_size(api_map[:metadata]) == 1
    end
  end

  describe "roundtrip conversion" do
    test "converts raw data to struct and back to API format" do
      raw_data = %{
        "id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
        "name" => "Daniel Lima",
        "devMode" => false,
        "cellphone" => "(11) 4002-8922",
        "taxId" => "123.456.789-01",
        "email" => "daniel_lima@abacatepay.com",
        "country" => "BR",
        "zipCode" => "12345-678",
        "metadata" => %{"key" => "value"}
      }

      assert {:ok, customer} = Customer.build_struct(raw_data)
      assert {:ok, api_map} = Customer.build_raw(customer)

      assert api_map[:id] == raw_data["id"]
      assert api_map[:name] == raw_data["name"]
      assert api_map[:devMode] == raw_data["devMode"]
      assert api_map[:cellphone] == raw_data["cellphone"]
      assert api_map[:taxId] == raw_data["taxId"]
      assert api_map[:email] == raw_data["email"]
      assert api_map[:country] == raw_data["country"]
      assert api_map[:zipCode] == raw_data["zipCode"]
      assert api_map[:metadata] == raw_data["metadata"]
    end
  end
end
