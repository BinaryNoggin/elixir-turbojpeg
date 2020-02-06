defmodule TurbojpegTest do
  use ExUnit.Case
  use PropCheck
  use Mogrify.Options

  import Mogrify
  # import ExUnit.CaptureIO, only: [capture_io: 1]

  alias Mogrify.Image
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

  property "jpeg and yuv conversion are complementary after running through the tool once" do
    forall [width, height, seed, {sampling_factor, format}] <- [
             width(),
             height(),
             seed(),
             format()
           ] do
      jpeg =
        %Image{}
        |> custom("size", "#{width}x#{height}")
        |> custom("seed", seed)
        |> custom("plasma", "fractal")
        |> custom("sampling-factor", sampling_factor)
        |> custom("stdout", "jpg:-")
        |> create(buffer: true)

      jpeg = Shmex.new(jpeg.buffer)
      {:ok, yuv} = Turbojpeg.Native.jpeg_to_yuv(jpeg)
      {:ok, new_jpeg} = Turbojpeg.Native.yuv_to_jpeg(yuv, width, height, 100, format)
      {:ok, original_header} = Turbojpeg.Native.get_jpeg_header(jpeg)
      {:ok, new_header} = Turbojpeg.Native.get_jpeg_header(new_jpeg)
      assert original_header == new_header
    end
  end

  def width do
    pos_integer()
  end

  def height do
    pos_integer()
  end

  def seed do
    pos_integer()
  end

  def format do
    oneof([{"4:2:0", :I420}, {"4:4:4", :I444}, {"4:2:2", :I422}])
  end
end
