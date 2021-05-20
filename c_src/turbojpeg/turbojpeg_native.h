#pragma once

#include <erl_nif.h>
#include <turbojpeg.h>

/** NIF State */
typedef struct _turbojpeg_native_state {
} UnifexNifState;

// /** NIF State */
typedef UnifexNifState State;

#include "_generated/turbojpeg_native.h"