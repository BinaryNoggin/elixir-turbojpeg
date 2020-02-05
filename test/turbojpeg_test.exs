defmodule TurbojpegTest do
  use ExUnit.Case
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
end
