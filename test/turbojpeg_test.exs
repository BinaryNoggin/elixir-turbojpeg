defmodule TurbojpegTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 10]
  use Mogrify.Options

  # import ExUnit.CaptureIO, only: [capture_io: 1]

  @jpeg_header <<255, 216, 255>>
  @i420_fixture "fixture/i420.yuv"
  @ff0000_fixture "fixture/ff0000_i444.jpg"

  test "Converts an i420 frame into a jpeg" do
    frame = File.read!(@i420_fixture)
    shmex = Shmex.new(frame)
    {:ok, jpeg} = Turbojpeg.Native.yuv_to_jpeg(shmex, 1920, 1080, 100, :I420)
    assert match?(@jpeg_header <> _, Shmex.to_binary(jpeg))
  end

  test "extracts i444 frame from jpeg" do
    jpeg = Shmex.new(File.read!(@ff0000_fixture))
    {:ok, yuv} = Turbojpeg.Native.jpeg_to_yuv(jpeg)
    {:ok, new_jpeg} = Turbojpeg.Native.yuv_to_jpeg(yuv, 64, 64, 100, :I444)
    assert Shmex.to_binary(jpeg) == Shmex.to_binary(new_jpeg)
  end

  test "get jpeg header" do
    jpeg = Shmex.new(File.read!(@ff0000_fixture))
    {:ok, result} = Turbojpeg.Native.get_jpeg_header(jpeg)
    assert result.width == 64
    assert result.height == 64
    assert result.format == :I444
  end

  property "solid color jpeg complementary", :verbose do
    forall [width, height, seed, {r, g, b}, {sampling_factor, _format}] <- [
             width(),
             height(),
             seed(),
             rgb(),
             format()
           ] do
      color = :io_lib.format('#~2.16.0B~2.16.0B~2.16.0B', [r, g, b])

      jpeg =
        %Mogrify.Image{}
        |> Mogrify.custom("size", "#{width}x#{height}")
        |> Mogrify.custom("seed", seed)
        |> Mogrify.custom("canvas", to_string(color))
        |> Mogrify.custom("sampling-factor", sampling_factor)
        |> Mogrify.custom("stdout", "jpg:-")
        |> Mogrify.create(buffer: true)

      jpeg = Shmex.new(jpeg.buffer)
      {:ok, yuv} = Turbojpeg.Native.jpeg_to_yuv(jpeg)

      {:ok, original_header} = Turbojpeg.Native.get_jpeg_header(jpeg)

      {:ok, new_jpeg} =
        Turbojpeg.Native.yuv_to_jpeg(yuv, width, height, 100, original_header.format)

      {:ok, new_header} = Turbojpeg.Native.get_jpeg_header(new_jpeg)

      assert original_header == new_header

      aggregate(true,
        # size: to_range(10_000, width * height) |> as_bytes(1024)
        # width: to_range(500, width),
        # height: to_range(500, height),
        r: to_range(51, r),
        g: to_range(51, g),
        b: to_range(51, b)
      )

      # does not work yet
      # assert Shmex.to_binary(jpeg) == Shmex.to_binary(new_jpeg)
    end
  end

  property "jpeg and yuv conversion are complementary after running through the tool once", [
    :verbose
  ] do
    forall [width, height, seed, {sampling_factor, format}] <- [
             width(),
             height(),
             seed(),
             format()
           ] do
      jpeg =
        %Mogrify.Image{}
        |> Mogrify.custom("size", "#{width}x#{height}")
        |> Mogrify.custom("seed", seed)
        |> Mogrify.custom("plasma", "fractal")
        |> Mogrify.custom("sampling-factor", sampling_factor)
        |> Mogrify.custom("stdout", "jpg:-")
        |> Mogrify.create(buffer: true)

      jpeg = Shmex.new(jpeg.buffer)
      {:ok, yuv} = Turbojpeg.Native.jpeg_to_yuv(jpeg)
      {:ok, new_jpeg} = Turbojpeg.Native.yuv_to_jpeg(yuv, width, height, 100, format)
      {:ok, original_header} = Turbojpeg.Native.get_jpeg_header(jpeg)
      {:ok, new_header} = Turbojpeg.Native.get_jpeg_header(new_jpeg)
      assert original_header == new_header

      aggregate(true,
        size: to_range(10_000, width * height) |> as_bytes(1024)
        # width: to_range(500, width),
        # height: to_range(500, height),
        # format: format
      )
    end
  end

  def to_range(size, n) do
    base = div(n, size)
    {base * size, (base + 1) * size}
  end

  def as_bytes({min, max}, size) do
    {div(min, size), div(max, size)}
  end

  def width do
    length()
  end

  def height do
    length()
  end

  def length do
    sized(s, resize(s * 100, pos_integer()))
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
