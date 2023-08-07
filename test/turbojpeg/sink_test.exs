defmodule Turbojpeg.SinkTest do
  @moduledoc false

  use ExUnit.Case

  alias Turbojpeg.Sink

  @moduletag :tmp_dir

  @stream_format %Membrane.RawVideo{
    width: 1920,
    height: 1080,
    aligned: true,
    pixel_format: :I420,
    framerate: nil
  }

  @in_path "fixture/i420.yuv"
  @ctx %{pads: %{input: %{stream_format: @stream_format}}}

  setup %{tmp_dir: tmp_dir} do
    %{out_path: Path.join(tmp_dir, "image.jpeg")}
  end

  test "write yuv data to a jpeg file", %{out_path: out_path} do
    yuv = File.read!(@in_path)
    {:ok, jpeg} = Turbojpeg.yuv_to_jpeg(yuv, 1920, 1080, 56, :I420)

    assert {[], state} = Sink.handle_init(@ctx, %Sink{filename: out_path, quality: 56})

    assert {[], %{width: 1920, height: 1080, format: :I420} = state} =
             Sink.handle_stream_format(:input, @stream_format, @ctx, state)

    assert {[], _state} = Sink.handle_write(:input, %Membrane.Buffer{payload: yuv}, @ctx, state)

    assert File.exists?(out_path)
    assert File.read!(out_path) == jpeg
  end

  test "raise if stream format is updated" do
    new_stream_format = get_in(@ctx, [:pads, :input, :stream_format])
    assert {[], state} = Sink.handle_init(@ctx, %Sink{filename: ""})

    assert_raise RuntimeError, fn ->
      Sink.handle_stream_format(
        :input,
        %Membrane.RawVideo{new_stream_format | height: 1440},
        @ctx,
        state
      )
    end
  end
end
