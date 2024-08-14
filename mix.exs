defmodule ExAwsCodePipeline.MixProject do
  use Mix.Project

  @source_url "https://github.com/fmcgeough/ex_aws_code_pipeline"
  @version "2.1.0"

  def project do
    [
      app: :ex_aws_code_pipeline,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      description: "AWS Code Pipeline service for ex_aws",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "1.6.3 or 1.6.5 or 1.7.1 or 1.8.6 or ~> 1.9", only: [:dev, :test]},
      {:poison, ">= 1.2.0", optional: true},
      {:ex_aws, "~> 2.0"},
      {:ex_doc, "~> 0.34.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Frank McGeough"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      name: "ExAws.CodeDeploy",
      canonical: "http://hexdocs.pm/ex_aws_code_deploy",
      source_url: @source_url,
      main: "readme",
      extras: ["README.md", "CHANGELOG.md": [title: "Changelog"], LICENSE: [title: "License"]]
    ]
  end
end
