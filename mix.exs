defmodule Turbojpeg.MixProject do
  use Mix.Project

  @version "0.4.0"
  @github_link "https://github.com/binarynoggin/elixir-turbojpeg"

  def project do
    [
      compilers: [:unifex, :bundlex] ++ Mix.compilers(),
      app: :turbojpeg,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: "Elixir bindings for libjpeg-turbo",
      source_url: @github_link,
      homepage_url: @github_link,
      package: package(),
      docs: docs(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings.exs"
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
      {:bundlex, "~> 1.4.0"},
      {:unifex, "~> 1.1.0"},
      {:membrane_core, "~> 1.0"},
      {:membrane_raw_video_format, "~> 0.3.0"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:propcheck, "~> 1.4.0", only: [:test]},
      {:mogrify, "~> 0.9.0", only: [:test, :dev]},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
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
