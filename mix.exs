defmodule StatefulProperty.MixProject do
  use Mix.Project

  def project do
    [
      app: :stateful_property,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      test_pattern: "*_{test,proper}.exs",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {StatefulProperty.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:propcheck, "~> 1.1"},#, only: [:test, :dev]},
      {:dialyxir, "~> 0.4"}#, only: [:dev]},
    ]
  end
end
