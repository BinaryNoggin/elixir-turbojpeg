#include "turbojpeg_native.h"

/** 
 * Supported pixel formats: :I420 | :I422 | :I444 
 * Unsupported pixel formats: :RGB | :BGRA | :RGBA | :NV12 | :NV21 | :YV12 | :AYUV
*/
int format_to_tjsamp(char* format) {
  if(strcmp(format, "I420") == 0) {
    return TJSAMP_420;
  } else if(strcmp(format, "I422") == 0) {
    return TJSAMP_422;
  } else if(strcmp(format, "I444") == 0) {
    return TJSAMP_444;
  } else {
    return -1;
  }
}

/** 
 * Supported pixel formats: :I420 | :I422 | :I444 
 * Unsupported pixel formats: :RGB | :BGRA | :RGBA | :NV12 | :NV21 | :YV12 | :AYUV
*/
const char* tjsamp_to_format(enum TJSAMP tjsamp) {
  switch(tjsamp) {
    case(TJSAMP_420):
      return("I420");
    case(TJSAMP_422):
      return("I422");
    case(TJSAMP_444):
      return("I444");
    default:
      return("unknown_format");
  }
}

/**
 * Returns %{height: int, width: int, format: atom}
*/
UNIFEX_TERM get_jpeg_header(UnifexEnv* env, UnifexPayload *payload) {
  tjhandle tjh;
  enum TJSAMP tjsamp;
  enum TJCS cspace;
  int res, width, height;
  ERL_NIF_TERM map_out, ret;

  tjh = tjInitDecompress();
  if(!tjh)
    return get_jpeg_header_result_error(env, tjGetErrorStr());

  res = tjDecompressHeader3(
    tjh,
    payload->data,
    payload->size, 
    &width, &height, 
    (int*)&tjsamp, (int*)&cspace
  );
  if(res < 0) {
    ret = get_jpeg_header_result_error(env, tjGetErrorStr2(tjh));
    goto cleanup;
  }

  // unifex does not support maps yes.
  // See https://github.com/membraneframework/unifex/issues/32
  if(!enif_make_map_from_arrays(
    env,
    (ERL_NIF_TERM []) {
      enif_make_atom(env, "width"),
      enif_make_atom(env, "height"),
      enif_make_atom(env, "format"),

    },
    (ERL_NIF_TERM []) {
      enif_make_int(env, width),
      enif_make_int(env, height),
      enif_make_atom(env, tjsamp_to_format(tjsamp))
    },
    3, &map_out
  )) {
    ret = get_jpeg_header_result_error(env, "make_map");
    goto cleanup;
  } else {
    // Generated code does not support maps currently.
    ret = enif_make_tuple_from_array(env, (ERL_NIF_TERM []) {enif_make_atom(env, "ok"), map_out}, 2);
    goto cleanup;
  }
cleanup:
  if(tjh) tjDestroy(tjh);
  return ret;
}

/**
 * Convert a binary h264 payload into a jpeg encoded payload
*/
UNIFEX_TERM yuv_to_jpeg(UnifexEnv* env, UnifexPayload *payload, int width, int height, int quality, char* format) {
  tjhandle tjh = NULL;
  enum TJSAMP tjsamp;
  unsigned char *jpegBuf = NULL;
  unsigned long jpegSize;
  int res;
  UnifexPayload *jpegFrame;
  UNIFEX_TERM ret;

  res = format_to_tjsamp(format);
  if(res < 0) {
    return(yuv_to_jpeg_result_error(env, "unsupported_format")); 
  } else {
    tjsamp = (enum TJSAMP)res;
  }

  tjh = tjInitCompress();
  if(!tjh)
    return yuv_to_jpeg_result_error(env, tjGetErrorStr());
  
  res = tjCompressFromYUV(
    tjh, 
    payload->data, 
    width, 4, height, tjsamp, 
    &jpegBuf, &jpegSize, 
    quality, 0
  );

  if(res < 0) {
    ret = yuv_to_jpeg_result_error(env, tjGetErrorStr2(tjh));
    goto cleanup;
  } else {
    jpegFrame = unifex_payload_alloc(env, UNIFEX_PAYLOAD_SHM, jpegSize);
    if(!jpegFrame) {
      ret = yuv_to_jpeg_result_error(env, "payload_alloc");
    } else {
      memcpy(jpegFrame->data, jpegBuf, jpegSize);
      ret = yuv_to_jpeg_result_ok(env, jpegFrame);
    }
    goto cleanup;
  }

cleanup:
  if(jpegBuf) tjFree(jpegBuf);
  if(tjh) tjDestroy(tjh);
  return ret;
}

/**
 * Convert a binary jpeg payload into a yuv encoded payload
*/
UNIFEX_TERM jpeg_to_yuv(UnifexEnv* env, UnifexPayload *payload) {
  tjhandle tjh;
  enum TJSAMP tjsamp;
  enum TJCS cspace;
  unsigned long yuvBufSize;
  UnifexPayload *yuvFrame;
  int res, width, height;
  UNIFEX_TERM ret;

  tjh = tjInitDecompress();
  if(!tjh)
    return jpeg_to_yuv_result_error(env, tjGetErrorStr());

  res = tjDecompressHeader3(
    tjh,
    payload->data,
    payload->size, 
    &width, &height, 
    (int*)&tjsamp, (int*)&cspace
  );
  if(res < 0) {
    ret = jpeg_to_yuv_result_error(env, tjGetErrorStr2(tjh));
    goto cleanup;
  } 
  
  yuvBufSize = tjBufSizeYUV2(width, 4, height, tjsamp);
  yuvFrame = unifex_payload_alloc(env, UNIFEX_PAYLOAD_SHM, yuvBufSize);
  if(!yuvFrame) {
    ret = jpeg_to_yuv_result_error(env, "could not allocate frame");
    goto cleanup;
  }

  res = tjDecompressToYUV2(
    tjh, 
    payload->data,
    payload->size,
    yuvFrame->data,
    width, 4, height,
    0
	);

  if(res < 0) {
    ret = jpeg_to_yuv_result_error(env, tjGetErrorStr2(tjh));
    goto cleanup;
  } else {
    ret = jpeg_to_yuv_result_ok(env, yuvFrame);
    goto cleanup;
  }

cleanup:
  if(tjh) tjDestroy(tjh);
  return ret;
}

void handle_destroy_state(UnifexEnv* env, State* state) {
  UNIFEX_UNUSED(env);
  UNIFEX_UNUSED(state);
}