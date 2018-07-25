defmodule SampleApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :sample_app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SampleApp, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.0"},
      {:plug_health_check, path: "../"}
    ]
  end
end
