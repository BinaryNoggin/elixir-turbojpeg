module Turbojpeg.Native

spec create(width::int, height::int, quality::int, format::atom) :: {:ok :: label, state} | {:error :: label, reason :: atom}
spec to_jpeg(payload, state) :: {:ok :: label, payload} | {:error :: label, reason :: atom}