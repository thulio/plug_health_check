defmodule PlugHealthCheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_health_check,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      applications: [:plug],
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:junit_formatter, "~> 2.2", only: [:test]}
    ]
  end
end
