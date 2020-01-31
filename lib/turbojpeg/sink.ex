defmodule Turbojpeg.Sink do
  alias Turbojpeg.Native
  use Membrane.Sink
  alias Membrane.{Buffer, Time}
  alias Membrane.Caps.Video.Raw

  def_input_pad(:input, caps: Raw, demand_unit: :buffers)

  def_options(
    filename: [type: :binary, description: "File to write the jpeg file"],
    quality: [type: :integer, description: "Jpeg encoding quality"]
  )

  @impl true
  def handle_init(options) do
    state = %{
      quality: options.quality,
      filename: options.filename,
      jpeg_ref: nil,
      timer_started?: false
    }

    {:ok, state}
  end

  @impl true
  def handle_start_of_stream(:input, ctx, state) do
    use Ratio
    {nom, denom} = ctx.pads.input.caps.framerate
    timer = {:demand_timer, Time.seconds(denom) <|> nom}

    {{:ok, demand: :input, start_timer: timer}, %{state | timer_started?: true}}
  end

  @impl true
  def handle_caps(:input, caps, ctx, state) do
    %{input: input} = ctx.pads

    if !input.caps || caps == input.caps do
      {:ok, ref} = Native.create(caps.width, caps.height, state.quality, caps.format)
      {:ok, %{state | jpeg_ref: ref}}
    else
      raise "Caps have changed while playing. This is not supported."
    end
  end

  @impl true
  def handle_write(:input, %Buffer{payload: payload}, _ctx, state) do
    with {:ok, data} <- Native.to_jpeg(payload, state.jpeg_ref),
         :ok <- File.write(state.filename, Shmex.to_binary(data)) do
      {:ok, state}
    else
      {:error, reason} ->
        {{:error, reason}, state}
    end
  end

  @impl true
  def handle_tick(:demand_timer, _ctx, state) do
    {{:ok, demand: :input}, state}
  end
end
