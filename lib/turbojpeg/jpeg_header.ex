defmodule Turbojpeg.JpegHeader do
  @moduledoc """
  Structure representing JPEG image header information.
  """

  @typedoc """
  The header contains the following information:
    * `width` - The width of the image.
    * `height` - The height of the image.
    * `format` - The pixel format of the image.
  """
  @type t :: %__MODULE__{
          width: Turbojpeg.dimension(),
          height: Turbojpeg.dimension(),
          format: Turbojpeg.format()
        }

  defstruct [:width, :height, :format]
end
