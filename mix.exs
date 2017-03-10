defmodule DistilleryPackager.Mixfile do
  use Mix.Project

  def project do
    [app: :distillery_packager,
     version: "0.3.5",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:distillery, "~> 1.2"},
      {:vex,        "~> 0.5"},
      {:timex,      "~> 3.0"},
      {:credo,      "~> 0.6", only: [:dev, :test], runtime: false},
      {:dogma,      "~> 0.1", only: [:dev, :test], runtime: false}
    ]
  end
end
