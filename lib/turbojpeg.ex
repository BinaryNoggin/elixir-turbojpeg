defmodule Turbojpeg do
  @moduledoc File.read!("README.md")

  alias Turbojpeg.{JpegHeader, Native}

  @type width :: dimension
  @type height :: dimension
  @type dimension :: pos_integer()
  @type quality :: 0..100
  @type format ::
          :I420
          | :I422
          | :I444
          | :GRAY
  @type error :: {:error, atom()} | {:error, struct}

  @doc """
  Converts yuv to jpeg images


        iex> {:ok, jpeg} = Turbojpeg.yuv_to_jpeg(frame, 1920, 1080, 90, :I420)
          {:ok, <<....>>}
  """
  @spec yuv_to_jpeg(binary(), width, height, quality, format) ::
          {:ok, binary()} | error()
  def yuv_to_jpeg(yuv, width, height, quality, format) do
    Native.yuv_to_jpeg(yuv, width, height, quality, format)
  end

  @doc """
  Converts jpeg to yuv


        iex> {:ok, yuv} = Turbojpeg.jpeg_to_yuv(jpeg)
          {:ok,<<..>>}
  """
  @spec jpeg_to_yuv(binary()) :: {:ok, binary()} | error()
  def jpeg_to_yuv(jpeg) do
    Native.jpeg_to_yuv(jpeg)
  end

  @doc """
  Gets the header from a jpeg binary

  ## Examples

      iex> {:ok, header} = Turbojpeg.get_jpeg_header(jpeg)
         {:ok,
           %Turbojpeg.JpegHeader{
              format: :I422,
              width: 192,
              height: 192
            }
         }

      iex> Turbojpeg.get_jpeg_header(<<45, 48, 44, 41, 11>>)
         {:error, "Not a JPEG file: starts with 0x2d 0x30"}
  """
  @spec get_jpeg_header(binary()) :: {:ok, JpegHeader.t()} | error()
  def get_jpeg_header(jpeg) do
    Native.get_jpeg_header(jpeg)
  end
end
