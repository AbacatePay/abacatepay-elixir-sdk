![Build Status](https://github.com/AbacatePay/abacatepay-elixir-sdk/actions/workflows/check.yml/badge.svg)

This is the official [AbacatePay SDK](https://www.abacatepay.com) in [Elixir](https://elixir-lang.org/) - Accept payments in seconds with a simple integration.

## Getting Started

### Installation

The package can be installed by adding `abacatepay` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:abacatepay, "~> 0.2.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/abacatepay](https://hexdocs.pm/abacatepay).

### Configuration

AbacatePay has a range of configuration options, but most applications will have a configuration that looks like the following:

```elixir
# config/config.exs
config :abacatepay,
  api_key: "abc_dev_pWxM5GhSROzeerqmdkfu6mNN"
```

### Usage

This example demonstrates how to create a new customer and a new billing using our SDK.

```elixir
# Creating a new Customer
{:ok, customer} = AbacatePay.Customer.create([
  name: "Daniel Lima",
  cellphone: "(11) 4002-8922",
  email: "daniel_lima@abacatepay.com",
  tax_id: "123.456.789-01"
])
# %AbacatePay.Customer{id: "cust_aebxkhDZNaMmJeKsy0AHS0FQ", name: "Daniel Lima", cellphone: "(11) 4002-8922", email: "daniel_lima@abacatepay.com", tax_id: "123.456.789-01"}

# Listing the Products to be included in the Billing
listed_products = [
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

# Creating a new Billing
{:ok, billing} = AbacatePay.Billing.create([
  frequency: :one_time,
  methods: [:pix, :card],
  products: listed_products,
  customer: customer,
  return_url: "https://example.com/return",
  completion_url: "https://example.com/completion",
  allow_coupons: true,
  coupons: ["DEYVIN_20"],
  external_id: "order_0001",
  metadata: %{"notes" => "First order"}
])
# %AbacatePay.Billing{id: "bill_aebxkhDZNaMmJeKsy0AHS0FQ", frequency: :one_time, methods: [:pix, :card], ...}
```
