defmodule Chalk.MixProject do
  use Mix.Project

  def project do
    [
      app: :chalk,
      version: "0.1.0",
      elixir: "~> 1.10",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Chalk",
      homepage_url: "https://github.com/thalesflores/chalk",
      source_url: "https://github.com/thalesflores/chalk",
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: dialyzer_config(),
      preferred_cli_env: [dialyzer: :test],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.21", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: [:dev, :test], runtime: false},
      {:bypass, "~> 1.0", only: :test},
      {:plug_cowboy, "~> 2.0", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      source_url: "https://github.com/thalesflores/chalk",
      extras: ["README.md"]
    ]
  end

  defp dialyzer_config do
    [
      plt_file: {:no_warn, "plts/dialyzer.plt"},
      plt_add_apps: [:mix, :ex_unit]
    ]
  end

  defp description do
    "A light GraphQL client to Elixir projects."
  end

  defp package do
    [
      name: "chalk",
      maintainers: ["Thales Flores"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/thalesflores/chalk"}
    ]
  end
end
