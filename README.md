<div align="center">

# AbacatePay Elixir

Official **AbacatePay Elixir** SDK to integrate payments via PIX in a simple, secure and fast way.

<img src="https://res.cloudinary.com/dkok1obj5/image/upload/v1767631413/avo_clhmaf.png" width="100%" alt="AbacatePay Open Source"/>

![Build Status](https://github.com/AbacatePay/abacatepay-elixir-sdk/actions/workflows/check.yml/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/abacatepay.svg)](https://hex.pm/packages/abacatepay)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/abacatepay)

</div>

<div align="center">

## Installation

The package can be installed by adding `abacatepay` to your list of dependencies in `mix.exs`:

</div>

```elixir
def deps do
  [
    {:abacatepay, "~> 0.2.0"}
  ]
end
```

<div align="center">

## Configuration

The SDK has a range of configuration options, but most applications will have a configuration that looks like the following:

</div>

```elixir
# config/config.exs
config :abacatepay,
  api_key: "abc_dev_pWxM5GhSROzeerqmdkfu6mNN"
```

<div align="center">

## Features

### Customer Operations

#### Create Customer

Create a new customer in the AbacatePay system.

</div>

```elixir
customer_data = [
  name: "Daniel Lima",
  tax_id: "123.456.789-01",
  email: "daniel_lima@abacatepay.com",
  cellphone: "+5511999999999"
]

{:ok, customer} = AbacatePay.Customer.create(customer_data)
```

<div align="center">

#### List Customers

Retrieve a list of all customers.

</div>

```elixir
{:ok, customers} = AbacatePay.Customer.list()
```

<div align="center">

### Billing Operations

#### Create Billing

Create a new billing for a customer.

</div>

```elixir
# The customer associated with the Billing
customer = %AbacatePay.Customer{
  id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
  name: "Daniel Lima",
  tax_id: "123.456.789-01",
  email: "daniel_lima@abacatepay.com",
  cellphone: "+5511999999999"
}

# The products to be included in the Billing
products = [
  %AbacatePay.Product{
    name: "Product 1",
    price: 5000,
    quantity: 1
  },
  %AbacatePay.Product{
    name: "Product 2",
    price: 3000,
    quantity: 2
  }
]

billing_data = [
  frequency: :one_time,
  methods: [:pix, :card],
  products: products,
  customer: customer,
  return_url: "https://example.com/return",
  completion_url: "https://example.com/completion",
  allow_coupons: true,
  coupons: ["DEYVIN_20"],
  external_id: "order_0001",
  metadata: %{"notes" => "First order"}
]

{:ok, billing} = AbacatePay.Billing.create(billing_data)
```

<div align="center">

#### List Billings

Retrieve a list of all billings.

</div>

```elixir
{:ok, billings} = AbacatePay.Billing.list()
```

<div align="center">

### Response Types

#### Customer Response

</div>

```elixir
%AbacatePay.Customer{
  id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ",
  name: "Daniel Lima",
  tax_id: "123.456.789-01",
  email: "daniel_lima@abacatepay.com",
  cellphone: "+5511999999999"
}
```

<div align="center">

#### Billing Response

</div>

```elixir
%AbacatePay.Billing{
  id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ",
  frequency: :one_time,
  url: "https://app.abacatepay.com/pay/bill_aebxkhDZNaMmJeKsy0AHS0FQ",
  status: :pending,
  dev_mode: false,
  methods: [:pix, :card],
  products: [%AbacatePay.Product{name: "Product 1", price: 5000, quantity: 1}, %AbacatePay.Product{name: "Product 2", price: 3000, quantity: 2}],
  customer: %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", cellphone: "+5511999999999", email: "daniel_lima@abacatepay.com", tax_id: "123.456.789-01"},
  metadata: %{fee: 80, return_url: "https://example.com/return", completion_url: "https://example.com/completion"},
  next_billing: nil,
  allow_coupons: true,
  coupons: ["DEYVIN_20"],
  created_at: ~U[2026-01-01T12:00:00Z],
  updated_at: ~U[2026-01-02T12:00:00Z]
}
```

