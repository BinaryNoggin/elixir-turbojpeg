defmodule TurbojpegTest do
  use ExUnit.Case
  @jpeg_header <<255, 216, 255>>
  @i420_fixture "fixture/i420.yuv"

  test "Converts an i420 frame into a jpeg" do
    {:ok, native} = Turbojpeg.Native.create(1920, 1080, 75, :I420)
    frame = File.read!(@i420_fixture)
    shmex = Shmex.new(frame)
    {:ok, jpeg} = Turbojpeg.Native.to_jpeg(shmex, native)
    assert match?(@jpeg_header <> _, Shmex.to_binary(jpeg))
  end
end
