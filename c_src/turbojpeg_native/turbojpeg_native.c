#include "turbojpeg_native.h"

/** 
 * Supported pixel formats: :I420 | :I422 | :I444 
 * Unsupported pixel formats: :RGB | :BGRA | :RGBA | :NV12 | :NV21 | :YV12 | :AYUV
*/
UNIFEX_TERM create(UnifexEnv *env, int width, int height, int jpegQuality, char *format) {
  UNIFEX_TERM res;
  State *state = unifex_alloc_state(env);
  state->width = width; state->height = height; 
  state->flags = 0; state->quality = jpegQuality;
  if(strcmp(format, "I420") == 0) {
    state->format = TJSAMP_420;
  } else if(strcmp(format, "I422") == 0) {
    state->format = TJSAMP_422;
  } else if(strcmp(format, "I444") == 0) {
    state->format = TJSAMP_444;
  } else {
    res = create_result_error(env, "unsupported_format");
    unifex_release_state(env, state);
    return(res); 
  }
  res = create_result_ok(env, state);
  unifex_release_state(env, state);
  return(res);
}

/**
 * Convert a binary h264 payload into a jpeg encoded payload
*/
UNIFEX_TERM to_jpeg(UnifexEnv* env, UnifexPayload *payload, State *state) {
  state->tjh = tjInitCompress();
  
  unsigned char *jpegBuf = NULL;
  unsigned long jpegSize;

  int res = tjCompressFromYUV(
    state->tjh, 
    payload->data, 
    state->width, 4, state->height, state->format, 
    &jpegBuf, &jpegSize, 
    state->quality, state->flags
  );

  if(res) {
    return to_jpeg_result_error(env, tjGetErrorStr());
  } else {
    UnifexPayload *jpegFrame = unifex_payload_alloc(env, UNIFEX_PAYLOAD_SHM, jpegSize);
    memcpy(jpegFrame->data, jpegBuf, jpegSize);
    tjFree(jpegBuf);
    return to_jpeg_result_ok(env, jpegFrame);
  }
}

void handle_destroy_state(UnifexEnv* env, State* state) {
  UNIFEX_UNUSED(env);
  if(state->tjh) { tjDestroy(state->tjh); }
}