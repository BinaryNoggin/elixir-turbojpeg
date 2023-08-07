defmodule TurbojpegTest do
  @moduledoc false

  use ExUnit.Case
  use PropCheck, numtests: 10
  use Mogrify.Options

  alias Turbojpeg.JpegHeader

  @jpeg_header <<255, 216, 255>>
  @i420_fixture "fixture/i420.yuv"
  @ff0000_fixture "fixture/ff0000_i444.jpg"

  test "Converts an i420 frame into a jpeg" do
    frame = File.read!(@i420_fixture)
    {:ok, jpeg} = Turbojpeg.yuv_to_jpeg(frame, 1920, 1080, 100, :I420)
    assert match?(@jpeg_header <> _, jpeg)
  end

  test "extracts i444 frame from jpeg" do
    jpeg = File.read!(@ff0000_fixture)
    {:ok, yuv} = Turbojpeg.jpeg_to_yuv(jpeg)
    {:ok, new_jpeg} = Turbojpeg.yuv_to_jpeg(yuv, 64, 64, 100, :I444)
    assert jpeg == new_jpeg
  end

  test "get jpeg header" do
    jpeg = File.read!(@ff0000_fixture)
    {:ok, %JpegHeader{} = result} = Turbojpeg.get_jpeg_header(jpeg)
    assert result.width == 64
    assert result.height == 64
    assert result.format == :I444
  end

  property "solid color jpeg complementary" do
    forall [width, height, seed, {r, g, b}, {sampling_factor, _format}] <- [
             width(),
             height(),
             seed(),
             rgb(),
             format()
           ] do
      color = :io_lib.format(~c"#~2.16.0B~2.16.0B~2.16.0B", [r, g, b])

      jpeg =
        %Mogrify.Image{}
        |> Mogrify.custom("size", "#{width}x#{height}")
        |> Mogrify.custom("seed", seed)
        |> Mogrify.custom("canvas", to_string(color))
        |> Mogrify.custom("sampling-factor", sampling_factor)
        |> Mogrify.custom("stdout", "jpg:-")
        |> Mogrify.create(buffer: true)

      {:ok, yuv} = Turbojpeg.jpeg_to_yuv(jpeg.buffer)

      {:ok, original_header} = Turbojpeg.get_jpeg_header(jpeg.buffer)

      {:ok, new_jpeg} = Turbojpeg.yuv_to_jpeg(yuv, width, height, 100, original_header.format)

      {:ok, new_header} = Turbojpeg.get_jpeg_header(new_jpeg)

      assert original_header == new_header
    end
  end

  property "jpeg and yuv conversion are complementary after running through the tool once" do
    forall [width, height, seed, {sampling_factor, format}, quality] <- [
             width(),
             height(),
             seed(),
             format(),
             integer(0, 100)
           ] do
      jpeg =
        %Mogrify.Image{}
        |> Mogrify.custom("size", "#{width}x#{height}")
        |> Mogrify.custom("seed", seed)
        |> Mogrify.custom("plasma", "fractal")
        |> Mogrify.custom("sampling-factor", sampling_factor)
        |> Mogrify.custom("stdout", "jpg:-")
        |> Mogrify.create(buffer: true)

      {:ok, yuv} = Turbojpeg.jpeg_to_yuv(jpeg.buffer)
      {:ok, new_jpeg} = Turbojpeg.yuv_to_jpeg(yuv, width, height, quality, format)
      {:ok, original_header} = Turbojpeg.get_jpeg_header(jpeg.buffer)
      {:ok, new_header} = Turbojpeg.get_jpeg_header(new_jpeg)
      assert original_header == new_header
    end
  end

  def to_range(size, n) do
    base = div(n, size)
    {base * size, (base + 1) * size}
  end

  def as_bytes({min, max}, size) do
    {div(min, size), div(max, size)}
  end

  def width(multiplier \\ 10) do
    dimension(multiplier)
  end

  def height(multiplier \\ 10) do
    dimension(multiplier)
  end

  def dimension(multiplier) do
    sized(s, resize(s * multiplier, pos_integer()))
  end

  def seed do
    pos_integer()
  end

  def format do
    oneof([{"4:2:0", :I420}, {"4:4:4", :I444}, {"4:2:2", :I422}])
  end

  def rgb do
    {color(), color(), color()}
  end

  def color(), do: integer(0, 255)
end
