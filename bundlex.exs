defmodule Turbojpeg.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      natives: natives(Bundlex.platform())
    ]
  end

  def natives(_platform) do
    [
      turbojpeg_native: [
        interface: :nif,
        preprocessor: Unifex,
        sources: ["turbojpeg_native.c"],
        os_deps: [
          turbojpeg: [
            {:pkg_config, ["libturbojpeg"]}
          ]
        ]
      ]
    ]
  end
end
