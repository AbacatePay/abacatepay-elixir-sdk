defmodule AbacatePay.MixProject do
  use Mix.Project

  @app :abacatepay
  @description "Official AbacatePay Elixir SDK to integrate payments via PIX in a simple, secure and fast way."
  @name "AbacatePay"
  @version "0.3.0"
  @source_url "https://github.com/AbacatePay/abacatepay-elixir-sdk"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      description: @description,
      package: package(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      name: @name,
      source_url: @source_url,
      deps: deps(),
      dialyzer: dialyxir()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ elixirc_paths(:dev)
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {AbacatePay.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, "~> 1.1"},
      {:jason, "~> 1.4"},
      {:finch, "~> 0.21.0"},

      # Dev and test dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.0", only: :dev, runtime: false},
      {:mimic, "~> 2.0", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "LICENSE", "mix.exs", "*.md"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "GitHub" => @source_url,
        "AbacatePay" => "https://www.abacatepay.com"
      }
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      groups_for_modules: [
        API: [
          AbacatePay.Api.Billing,
          AbacatePay.Api.Coupon,
          AbacatePay.Api.Customer,
          AbacatePay.Api.Pix,
          AbacatePay.Api.PublicMRR,
          AbacatePay.Api.Store,
          AbacatePay.Api.Withdraw
        ],
        HTTP: [AbacatePay.HTTPClient, AbacatePay.ApiError],
        Resources: [
          AbacatePay.Billing,
          AbacatePay.Coupon,
          AbacatePay.Customer,
          AbacatePay.Pix,
          AbacatePay.Product,
          AbacatePay.PublicMRR,
          AbacatePay.Store,
          AbacatePay.Withdraw
        ],
        Utilities: [AbacatePay.Util]
      ],
      skip_undefined_reference_warnings_on: [
        "CHANGELOG.md"
      ]
    ]
  end

  defp dialyxir do
    [
      plt_local_path: "priv/plts/project",
      plt_core_path: "priv/plts/core"
    ]
  end
end
