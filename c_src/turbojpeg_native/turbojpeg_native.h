#pragma once

#include <erl_nif.h>
#include <turbojpeg.h>

/** NIF State */
typedef struct _h264_parser_state {
  /** Handle to turbojpeg */
  tjhandle tjh;
  enum TJSAMP format;
  int flags;
  int width; int height; int quality;
} UnifexNifState;

/** NIF State */
typedef UnifexNifState State;

#include "_generated/turbojpeg_native.h"