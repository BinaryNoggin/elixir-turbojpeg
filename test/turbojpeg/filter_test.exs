defmodule Turbojpeg.FilterTest do
  use ExUnit.Case
  import Membrane.Testing.Assertions
  alias Membrane.Testing

  defmodule MockSource do
    use Membrane.Source

    def_output_pad :output, mode: :push, caps: :any

    def_options yuv: [spec: binary], repeat: [spec: pos_integer]

    @impl true
    def handle_prepared_to_playing(_ctx, state) do
      buffers = %Membrane.Buffer{payload: state.yuv} |> Bunch.Enum.repeated(state.repeat)
      send(self(), :end_of_stream)
      {{:ok, buffer: {:output, buffers}}, state}
    end

    @impl true
    def handle_other(:end_of_stream, _ctx, state) do
      {{:ok, end_of_stream: :output}, state}
    end
  end

  test "integration test" do
    repeat = 5
    jpeg = File.read!("fixture/ff0000_i444.jpg")
    {:ok, yuv} = Turbojpeg.jpeg_to_yuv(jpeg)

    children = [
      source: %MockSource{yuv: yuv, repeat: repeat},
      parser: %Membrane.Element.RawVideo.Parser{format: :I444, width: 64, height: 64},
      filter: %Turbojpeg.Filter{quality: 100},
      sink: Membrane.Testing.Sink
    ]

    assert {:ok, pipeline} =
             Testing.Pipeline.start_link(%Testing.Pipeline.Options{elements: children})

    :ok = Testing.Pipeline.play(pipeline)
    assert_pipeline_playback_changed(pipeline, _, :playing)

    1..repeat
    |> Enum.each(fn _ ->
      assert_sink_buffer(pipeline, :sink, buffer)
      assert Shmex.to_binary(buffer.payload) == jpeg
    end)

    assert_end_of_stream(pipeline, :sink)
    refute_sink_buffer(pipeline, :sink, _, 0)
  end
end
