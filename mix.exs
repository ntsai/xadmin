defmodule XAdmin.Mixfile do
  use Mix.Project

  @version "0.0.1-dev"

  def project do
    [ app: :xadmin,
      version: @version,
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      name: "XAdmin",
      docs: [extras: ["README.md"], main: "XAdmin"],
      deps: deps,
      package: package,
      description: """
      An Elixir Phoenix Auto Administration Package.
      """
    ]
  end

  def application do
    [ applications: applications(Mix.env)]
  end

  defp applications(:test) do
    [:plug | applications(:prod)]
  end
  defp applications(_) do
    [:gettext, :phoenix, :ecto, :logger, :ex_queb, :xain]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [
      {:decimal, "~> 1.0"},
      {:phoenix, ">= 1.1.6"},
      {:ecto, "~> 2.0", override: true},
      {:phoenix_ecto, "~> 3.0.0"},
      {:postgrex, ">= 0.9.0", only: :test},
      {:floki, "~> 0.8", only: :test},
      {:cowboy, "~> 1.0"},
      {:phoenix_html, "~> 2.5"},
      {:inflex, "~> 1.7"},
      {:scrivener_ecto, github: "drewolson/scrivener_ecto"},
      {:xain, "~> 0.6"},
      {:csvlixir, "~> 1.0.0"},
      {:exactor, "~> 2.2.0"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_queb, "~> 0.2"},
      {:gettext, "~> 0.11"}
    ]
  end

  defp package do
    [ maintainers: ["Stephen Pallen", "Roman Smirnov"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/ntsai/xadmin" },
      files: ~w(lib priv web README.md package.json mix.exs LICENSE brunch-config.js AdminLte-LICENSE)]
  end
end
