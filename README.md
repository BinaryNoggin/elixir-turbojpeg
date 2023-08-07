# TurboJPEG

Fast JPEG encoding from raw YUV data using [libjpeg-turbo](https://libjpeg-turbo.org/)

[![CircleCI](https://circleci.com/gh/BinaryNoggin/elixir-turbojpeg/tree/master.svg?style=svg)](https://circleci.com/gh/BinaryNoggin/elixir-turbojpeg/tree/master)

## Installation

This library requires libjpeg-turbo to be installed

### Arch linux

    sudo pacman -S libjpeg-turbo

### Ubuntu/Debian

    sudo apt-get install libturbojpeg libturbojpeg0-dev

### OSX

    brew install libjpeg-turbo
    
### Develement Dependencies

### Arch linux

    sudo pacman -S imagemagick

### Ubuntu/Debian

    sudo apt-get install imagemagick

### OSX

    brew install imagemagick

If [available in Hex](https://hex.pm/packages/turbojpeg), the package can be installed
by adding `turbojpeg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:turbojpeg, "~> 0.3"}
  ]
end
```

## Basic Usage

```elixir 
iex(1)> frame = File.read!("fixture/i420.yuv")
<<0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>
iex(2)> {:ok, jpeg} = Turbojpeg.yuv_to_jpeg(frame, 1920, 1080, 90, :I420)
{:ok, <<255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 255,
  219, 0, 67, 0, 3, 2, 2, 3, 2, 2, 3, 3, 3, 3, 4, 3, 3, 4, 5, 8, 5, 5, 4, 4, 5,
  10, 7, 7, 6, ...>>}
iex(3)> File.write!("test.jpg", jpeg)
:ok
```

## Membrane Sink Usage

In this example we'll read an H264 encoded frame and save it as a JPEG image

```elixir
defmodule Your.Module.Pipeline do
  use Membrane.Pipeline

  alias Membrane.{File, H264}

  @impl true
  def handle_init(_ctx, _opts) do
    children = [
      child(:source, %File.Source{location: "input.h264"})
      |> child(:parser, H264.Parser)
      |> child(:decoder, H264.FFmpeg.Decoder)
      |> child(:sink, %Turbojpeg.Sink{filename: "/tmp/frame.jpeg", quality: 100})
    ]

    {[spec: spec], %{}}
  end

  @impl true
  def handle_element_end_of_stream(:sink, _ctx, state) do
    {[terminate: :normal], state}
  end
end
```

# Copyright and License

Copyright 2023, Binary Noggin
