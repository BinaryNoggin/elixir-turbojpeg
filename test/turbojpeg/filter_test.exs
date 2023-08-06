defmodule Turbojpeg.FilterTest do
  use ExUnit.Case

  import Membrane.ChildrenSpec
  import Membrane.Testing.Assertions

  alias Membrane.Testing

  @stream_format %Membrane.RawVideo{
    width: 64,
    height: 64,
    pixel_format: :I444,
    framerate: nil,
    aligned: true
  }

  defp start_pipeline(jpeg, repeat) do
    {:ok, yuv} = Turbojpeg.jpeg_to_yuv(jpeg)
    data = List.duplicate(yuv, repeat)

    structure = [
      child(:source, %Testing.Source{output: data, stream_format: @stream_format})
      |> child(:filter, %Turbojpeg.Filter{quality: 100})
      |> child(:sink, Testing.Sink)
    ]

    Testing.Pipeline.start_link_supervised!(structure: structure)
  end

  test "integration test" do
    jpeg = File.read!("fixture/ff0000_i444.jpg")
    repeat = 5

    pid = start_pipeline(jpeg, repeat)
    assert_pipeline_play(pid)

    1..repeat
    |> Enum.each(fn _ ->
      assert_sink_buffer(pid, :sink, buffer)
      assert buffer.payload == jpeg
    end)

    assert_end_of_stream(pid, :sink)
  end
end
