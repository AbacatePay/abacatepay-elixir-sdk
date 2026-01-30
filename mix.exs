defmodule AbacatePay.MixProject do
  use Mix.Project

  @app :abacatepay
  @description "AbacatePay Elixir SDK for you to start receiving payments in seconds"
  @name "AbacatePay"
  @version "0.1.0"
  @source_url "https://github.com/AbacatePay/abacatepay-elixir-sdk"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      description: @description,
      start_permanent: Mix.env() == :prod,
      name: @name,
      source_url: @source_url,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.3"},
      {:ex_doc, "~> 0.40.0", only: :dev, runtime: false}
    ]
  end
end
