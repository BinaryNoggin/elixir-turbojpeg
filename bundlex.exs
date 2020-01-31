defmodule Turbojpeg.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      nifs: nifs(Bundlex.platform())
    ]
  end

  def nifs(_platform) do
    [
      turbojpeg_native: [
        deps: [unifex: :unifex, shmex: :lib],
        src_base: "turbojpeg_native",
        sources: ["_generated/turbojpeg_native.c", "turbojpeg_native.c"],
        pkg_configs: ["libturbojpeg"]
      ]
    ]
  end
end
