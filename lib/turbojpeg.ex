defmodule Turbojpeg do
  @moduledoc File.read!("README.md")
  alias Turbojpeg.Native

  @type width :: dimension
  @type height :: dimension
  @type dimension :: pos_integer()
  @type quality :: 0..100
  @type format ::
          :I420
          | :I422
          | :I444
          | :GRAY
  @type error ::
          {:error, atom()}
          | {:error, struct}
  @type jpeg_header :: %{
          format: format(),
          width: width(),
          height: height()
        }

  @spec yuv_to_jpeg(Shmex.t(), width, height, quality, format) ::
          {:ok, Shmex.t()} | error()
  def yuv_to_jpeg(yuv, width, height, quality, format) do
    Native.yuv_to_jpeg(yuv, width, height, quality, format)
  rescue
    error ->
      {:error, error}
  end

  @spec jpeg_to_yuv(Shmex.t()) ::
          {:ok, Shmex.t()} | error()
  def jpeg_to_yuv(jpeg) do
    Native.jpeg_to_yuv(jpeg)
  rescue
    error ->
      {:error, error}
  end

  @spec get_jpeg_header(Shmex.t()) :: {:ok, jpeg_header} | error()
  def get_jpeg_header(jpeg) do
    Native.get_jpeg_header(jpeg)
  rescue
    error ->
      {:error, error}
  end
end
