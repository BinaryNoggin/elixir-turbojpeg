module Turbojpeg.Native

type jpeg_header :: %Turbojpeg.JpegHeader{
  format: atom,
  width: int,
  height: int
}

spec yuv_to_jpeg(payload, width::int, height::int, quality::int, format::atom) :: {:ok :: label, payload} | {:error :: label, reason :: string}
spec jpeg_to_yuv(payload) :: {:ok :: label, payload} | {:error :: label, reason :: string}
spec get_jpeg_header(payload) :: {:ok :: label, jpeg_header} | {:error::label, reason :: string}

dirty :cpu, yuv_to_jpeg: 5, jpeg_to_yuv: 1, get_jpeg_header: 1
