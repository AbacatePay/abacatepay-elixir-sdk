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
      package: package(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      name: @name,
      source_url: @source_url,
      deps: deps(),
      dialyzer: dialyxir()
    ]
  end

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
      {:jason, "~> 1.4"},
      {:finch, "~> 0.21.0"},
      {:dialyxir, "~> 1.4.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "LICENSE", "mix.exs"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url, "AbacatePay" => "https://www.abacatepay.com"}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      main: @name
    ]
  end

  defp dialyxir do
    [
      plt_local_path: "priv/plts/project",
      plt_core_path: "priv/plts/core"
    ]
  end
end
