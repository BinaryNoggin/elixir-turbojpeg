defmodule Turbojpeg.Filter do
  @moduledoc """
  Membrane filter converting raw video frames to JPEG.
  """
  use Membrane.Filter
  alias Membrane.Buffer

  def_input_pad :input, demand_unit: :buffers, caps: Membrane.Caps.Video.Raw
  # TODO: implement JPEG caps
  def_output_pad :output, caps: :any

  def_options quality: [
                type: :integer,
                spec: Turbojpeg.quality(),
                default: 100,
                description: "Jpeg encoding quality"
              ]

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_caps(:input, _caps, _ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_process(:input, buffer, ctx, state) do
    %{caps: caps} = ctx.pads.input

    with {:ok, payload} <-
           Turbojpeg.yuv_to_jpeg(
             buffer.payload,
             caps.width,
             caps.height,
             state.quality,
             caps.format
           ) do
      buffer = %Buffer{buffer | payload: payload}
      {{:ok, buffer: {:output, buffer}}, state}
    else
      {:error, _} = error -> {error, state}
    end
  end
end
