# TurboJPEG

Fast JPEG encoding from raw YUV data using [libjpeg-turbo](https://libjpeg-turbo.org/)

[![CircleCI](https://circleci.com/gh/BinaryNoggin/elixir-turbojpeg/tree/master.svg?style=svg)](https://circleci.com/gh/BinaryNoggin/elixir-turbojpeg/tree/master)

## Installation

This library requires libjpeg-turbo to be installed

### Arch linux

    sudo pacman -S libjpeg-turbo

### Ubuntu/Debian

    sudo apt-get install libturbojpeg0-dev

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
    {:shmex, "~> 0.2.0"},
    {:turbojpeg, "~> 0.2.1"}
  ]
end
```

## Basic Usage

```elixir 
iex(1)> frame = File.read!("fixture/i420.yuv")
<<0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 2, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>
iex(2)> {:ok, jpeg} = Turbojpeg.yuv_to_jpeg(Shmex.new(frame), 1920, 1080, 90, :I420)
{:ok,
 %Shmex{
   capacity: 203783,
   guard: #Reference<0.938325095.2990669827.232440>,
   name: "/shmex-00000005607042890133#000",
   size: 203783
 }}
iex(4)> Shmex.to_binary(jpeg)
<<255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 255,
  219, 0, 67, 0, 3, 2, 2, 3, 2, 2, 3, 3, 3, 3, 4, 3, 3, 4, 5, 8, 5, 5, 4, 4, 5,
  10, 7, 7, 6, ...>>
iex(5)> File.write!("test.jpg", Shmex.to_binary(jpeg))
:ok
```

## Membrane Sink Usage

Pleas See [the membrane guide](https://membraneframework.org/guide/v0.5/pipeline.html#content)
before using this.

```elixir
defmodule Your.Module.Pipeline do
  use Membrane.Pipeline

  @impl true
  def handle_init(location) do
    children = %{
      source: %SomeMembraneSourceModule{location: location},
      decoder: Membrane.Element.FFmpeg.H264.Decoder,
      jpeg_converter: %Turbojpeg.Sink{filename: "/tmp/frame.jpeg", quality: 100},
    }

    links = [
      link(:source) 
      |> to(:decoder) 
      |> to(:jpeg_converter) 
    ]

    spec = %ParentSpec{
      children: children,
      links: links
    }

    {{:ok, spec: spec}, %{}}
  end

end
```

# Copyright and License

Copyright 2020, Binary Noggin
