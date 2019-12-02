defmodule DistilleryPackager.Mixfile do
  use Mix.Project

  def project do
    [app: :distillery_packager,
     version: "1.0.8",
     elixir: "~> 1.7",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       coveralls: :test,
       "coveralls.detail": :test,
       "coveralls.post": :test],
     package: package(),
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
      {:distillery,  "~> 2.1"},
      {:vex,         "~> 0.8"},
      {:timex,       "~> 3.6"},
      {:ex_doc,      "~> 0.21", only: :dev},
      {:credo,       "~> 1.1", only: [:dev, :test], runtime: false},
      {:dogma,       "~> 0.1", only: [:dev, :test], runtime: false},
      {:faker,       "~> 0.12", only: :test},
      {:excoveralls, "~> 0.11", only: :test},
    ]
  end

  defp description do
    """
    Elixir lib for creating Debian and RPM packages with Distillery.
    """
  end

  defp package do
    [name: :distillery_packager,
     files: ["lib", "mix.exs", "README*", "LICENSE*", "templates"],
     maintainers: ["18Months Dev Team <info@18months.it>"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/18Months/distillery_packager",
              "Docs" => "https://hexdocs.pm/distillery_packager"}]
  end
end
