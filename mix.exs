defmodule Turbojpeg.MixProject do
  use Mix.Project

  @version "0.2.0"
  @github_link "https://github.com/binarynoggin/elixir-turbojpeg"

  def project do
    [
      compilers: [:unifex, :bundlex] ++ Mix.compilers(),
      app: :turbojpeg,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: "Elixir bindings for libjpeg-turbo",
      source_url: @github_link,
      homepage_url: @github_link,
      package: package(),
      docs: docs(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:unifex, "~> 0.1"},
      {:shmex, "~> 0.2.0"},
      {:bundlex, "~> 0.2.6"},
      {:membrane_core, "~> 0.5.0"},
      {:ex_doc, "~> 0.21.3", only: [:dev], runtime: false},
      {:propcheck, "~> 1.2.0", only: [:test]},
      {:mogrify, github: "ConnorRigby/mogrify", branch: "master", only: [:test, :dev]},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      files: ["lib", "c_src", "mix.exs", "README*", "LICENSE*", ".formatter.exs", "bundlex.exs"],
      links: %{
        "GitHub" => @github_link,
        "Binary Noggin" => "https://binarynoggin.com/"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end
