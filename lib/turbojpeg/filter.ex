defmodule Turbojpeg.Filter do
  @moduledoc """
  Membrane filter converting raw video frames to JPEG.
  """
  use Membrane.Filter

  alias Membrane.Buffer
  alias Membrane.RawVideo
  alias Membrane.RemoteStream

  def_input_pad :input,
    flow_control: :auto,
    demand_unit: :buffers,
    accepted_format: %RawVideo{pixel_format: pix_fmt} when pix_fmt in [:I420, :I422, :I444]

  # TODO: implement JPEG stream format
  def_output_pad :output, flow_control: :auto, accepted_format: RemoteStream

  def_options quality: [
                spec: Turbojpeg.quality(),
                default: 75,
                description: "Jpeg encoding quality"
              ]

  @impl true
  def handle_init(_ctx, options) do
    {[], Map.from_struct(options)}
  end

  @impl true
  def handle_stream_format(:input, _stream_format, _ctx, state) do
    {[stream_format: {:output, %RemoteStream{type: :bytestream}}], state}
  end

  @impl true
  def handle_process(:input, %Buffer{payload: payload} = buffer, ctx, state) do
    %{stream_format: stream_format} = ctx.pads.input
    %{width: width, height: height, pixel_format: pix_fmt} = stream_format

    case Turbojpeg.yuv_to_jpeg(payload, width, height, state.quality, pix_fmt) do
      {:ok, jpeg} ->
        {[buffer: {:output, %Buffer{buffer | payload: jpeg}}], state}

      error ->
        raise """
        could not create JPEG image
        #{inspect(error)}
        """
    end
  end
end
