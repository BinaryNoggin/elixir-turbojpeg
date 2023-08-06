defmodule Turbojpeg.Sink do
  @moduledoc """
  Element responsible for converting YUV binary data to jpeg image format using `turbojpeg`.
  """

  use Membrane.Sink

  alias Membrane.{Buffer, RawVideo}

  @accepted_pixel_format [:I420, :I422, :I444]

  def_input_pad :input,
    flow_control: :auto,
    demand_unit: :buffers,
    accepted_format: %RawVideo{pixel_format: pix_fmt} when pix_fmt in @accepted_pixel_format

  def_options filename: [
                spec: binary(),
                description: "File to write the jpeg data"
              ],
              quality: [
                spec: non_neg_integer(),
                default: 75,
                description: "Jpeg encoding quality"
              ]

  @impl true
  def handle_init(_ctx, options) do
    state =
      options
      |> Map.from_struct()
      |> Map.merge(%{
        height: nil,
        width: nil,
        format: nil
      })

    {[], state}
  end

  @impl true
  def handle_stream_format(
        :input,
        %RawVideo{width: width, height: height} = stream_format,
        ctx,
        state
      ) do
    %{input: input} = ctx.pads

    if !input.stream_format || stream_format == input.stream_format do
      {[], %{state | width: width, height: height, format: stream_format.pixel_format}}
    else
      raise "Stream format have changed while playing. This is not supported."
    end
  end

  @impl true
  def handle_write(:input, %Buffer{payload: payload}, _ctx, state) do
    with {:ok, data} <-
           Turbojpeg.yuv_to_jpeg(payload, state.width, state.height, state.quality, state.format),
         :ok <- File.write(state.filename, data) do
      {[], state}
    else
      error ->
        raise """
        could not create a JPG file
        #{inspect(error)}
        """
    end
  end
end
