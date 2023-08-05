defmodule Turbojpeg.JpegHeader do
  @moduledoc false

  @type t :: %__MODULE__{
          width: Turbojpeg.dimension(),
          height: Turbojpeg.dimension(),
          format: Turbojpeg.format()
        }

  defstruct [:width, :height, :format]
end
