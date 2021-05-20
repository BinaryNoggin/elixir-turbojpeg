module Turbojpeg.Native

spec yuv_to_jpeg(payload, width::int, height::int, quality::int, format::atom) :: {:ok :: label, payload} | {:error :: label, reason :: atom}
spec jpeg_to_yuv(payload) :: {:ok :: label, payload} | {:error :: label, reason :: atom}
spec get_jpeg_header(payload) :: {:ok :: label, data::int} | {:error::label, reason::atom}
dirty :cpu, yuv_to_jpeg: 5, jpeg_to_yuv: 1, get_jpeg_header: 1