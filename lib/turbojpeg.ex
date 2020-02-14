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

  @doc """
  Converts yuv to jpeg images


        iex> {:ok, jpeg} = Turbojpeg.yuv_to_jpeg(Shmex.new(frame), 1920, 1080, 90, :I420)
          {:ok,
            %Shmex{
            capacity: 203783,
            guard: #Reference<0.938325095.2990669827.232440>,
            name: "/shmex-00000005607042890133#000",
            size: 203783
          }}
  """
  @spec yuv_to_jpeg(Shmex.t(), width, height, quality, format) ::
          {:ok, Shmex.t()} | error()
  def yuv_to_jpeg(yuv, width, height, quality, format) do
    Native.yuv_to_jpeg(yuv, width, height, quality, format)
  rescue
    error ->
      {:error, error}
  end

  @doc """
  Converts jpeg to yuv


        iex> {:ok, yuv} = Turbojpeg.jpeg_to_yuv(Shmex.new(jpeg))
          {:ok,
            %Shmex{
            capacity: 203783,
            guard: #Reference<0.938325095.2990669827.232440>,
            name: "/shmex-00000005607042890133#000",
            size: 203783
          }}
  """
  @spec jpeg_to_yuv(Shmex.t()) ::
          {:ok, Shmex.t()} | error()
  def jpeg_to_yuv(jpeg) do
    Native.jpeg_to_yuv(jpeg)
  rescue
    error ->
      {:error, error}
  end

  @doc """
  Gets the header from a jpegv

       iex> {:ok, header} = Turbojpeg.get_jpeg_header(Shmex.new(jpeg))
         {:ok,
           %{
              format: :I422,
              width: 192,
              height: 192
            }
         }
  """
  @spec get_jpeg_header(Shmex.t()) :: {:ok, jpeg_header} | error()
  def get_jpeg_header(jpeg) do
    Native.get_jpeg_header(jpeg)
  rescue
    error ->
      {:error, error}
  end
end
