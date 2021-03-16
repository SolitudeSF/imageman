import ../colors, ../images

when defined(windows):
  const libname = "libpng16(-16).dll"
elif defined(macosx):
  const libname = "libpng16(|.16).dylib"
else:
  const libname = "libpng16.so(|.16)"

const
  PNG_LIBPNG_VER_STRING = "1.6.37"
  PNG_INFO_tRNS = 0x0010'u16
  PNG_COMPRESSION_TYPE_DEFAULT = 0
  PNG_FILTER_TYPE_DEFAULT = 0
  PNG_INTERLACE_NONE = 0
  PNG_INTERLACE_ADAM7 = 1
  PNG_FILLER_AFTER = 1
  PNG_COLOR_MASK_PALETTE = 1
  PNG_COLOR_MASK_COLOR = 2
  PNG_COLOR_MASK_ALPHA = 4
  PNG_COLOR_TYPE_GRAY = 0
  PNG_COLOR_TYPE_RGB = PNG_COLOR_MASK_COLOR
  PNG_COLOR_TYPE_RGB_ALPHA = PNG_COLOR_MASK_COLOR or PNG_COLOR_MASK_ALPHA
  PNG_COLOR_TYPE_GRAY_ALPHA = PNG_COLOR_MASK_ALPHA

type
  PngStruct = object
  PngInfo = object
  PngRWFn = proc(png: ptr PngStruct, outBytes: ptr cuchar, count: csize_t)
  PngFlushFn = proc(png: ptr PngStruct)
  PngErrorFn = proc(png: ptr PngStruct, msg: cstring) {.cdecl.}

  DataReader = object
    start: pointer
    offset: uint
    limit: uint

  FilterKind* = enum
    fkNone = 0x08, fkSub = 0x10, fkUp = 0x20, fkAvg = 0x40, fkPaeth = 0x80

{.push importc, dynlib: libname, cdecl.}

proc png_create_read_struct(user_png_ver: cstring, error: pointer,
  error_fn, warn_fn: PngErrorFn): ptr PngStruct
proc png_create_write_struct(user_png_ver: cstring, error: pointer,
  error_fn, warn_fn: PngErrorFn): ptr PngStruct
proc png_create_info_struct(png: ptr PngStruct): ptr PngInfo
proc png_set_read_fn(png: ptr PngStruct, io: pointer, read_fn: PngRWFn)
proc png_set_write_fn(png: ptr PngStruct, io: pointer, read_fn: PngRWFn, flush_fn: PngFlushFn)
proc png_init_io(png: ptr PngStruct, file: File)
proc png_get_io_ptr(png: ptr PngStruct): pointer
proc png_get_image_width(png: ptr PngStruct, info: ptr PngInfo): cuint
proc png_get_image_height(png: ptr PngStruct, info: ptr PngInfo): cuint
proc png_get_valid(png: ptr PngStruct, info: ptr PngInfo, flag: cuint): cuint
proc png_get_bit_depth(png: ptr PngStruct, info: ptr PngInfo): cuchar
proc png_get_color_type(png: ptr PngStruct, info: ptr PngInfo): cuchar
proc png_set_strip_16(png: ptr PngStruct)
proc png_set_strip_alpha(png: ptr PngStruct)
proc png_set_palette_to_rgb(png: ptr PngStruct)
proc png_set_expand_gray_1_2_4_to_8(png: ptr PngStruct)
proc png_set_tRNS_to_alpha(png: ptr PngStruct)
proc png_set_gray_to_rgb(png: ptr PngStruct)
proc png_set_filter(png: ptr PngStruct, `method`, filters: cint)
proc png_set_filler(png: ptr PngStruct, filler: cuint, fillerLoc: cint)
proc png_set_compression_level(png: ptr PngStruct, level: cint)
proc png_set_IHDR(png: ptr PngStruct, info: ptr PngInfo, width, height: cuint,
  bit_depth, color_type, interlace_type, compression_type, filter_type: cint)
proc png_read_image(png: ptr PngStruct, image: ptr ptr cuchar)
proc png_write_image(png: ptr PngStruct, image: ptr ptr cuchar)
proc png_read_info(png: ptr PngStruct, image: ptr PngInfo)
proc png_read_end(png: ptr PngStruct, image: ptr PngInfo)
proc png_write_info(png: ptr PngStruct, image: ptr PngInfo)
proc png_write_end(png: ptr PngStruct, image: ptr PngInfo)
proc png_read_update_info(png: ptr PngStruct, image: ptr PngInfo)
proc png_destroy_read_struct(png: ptr ptr PngStruct, info, end_info: ptr ptr PngInfo)
proc png_destroy_write_struct(png: ptr ptr PngStruct, info, end_info: ptr ptr PngInfo)

{.pop.}

proc pngReadString(png: ptr PngStruct, outBytes: ptr cuchar, count: csize_t) =
  var reader = cast[ptr DataReader](png_get_io_ptr png)
  let address = cast[ptr cuchar](cast[uint](reader.start) + reader.offset)
  reader.offset += count.uint
  if reader.offset > reader.limit:
    raise newException(IOError, "Couldn't read PNG data")
  copyMem outBytes, address, count

proc errorHandler(png: ptr PngStruct, msg: cstring) {.cdecl.} =
  raise newException(IOError, $msg)

proc warningHandler(png: ptr PngStruct, msg: cstring) {.cdecl.} =
  discard

template readPNGImpl(body: untyped): untyped =
  let
    png {.inject.} = png_create_read_struct(PNG_LIBPNG_VER_STRING, nil, errorHandler, warningHandler)
    info = png_create_info_struct(png)

  body

  png_read_info png, info

  let
    readColorType = png_get_color_type(png, info).int
    bitDepth = png_get_bit_depth(png, info).int
    hasAlpha = (readColorType and PNG_COLOR_MASK_ALPHA) > 0

  if bitDepth == 16:
    png_set_strip_16 png

  if readColorType == PNG_COLOR_MASK_PALETTE:
    png_set_palette_to_rgb png

  if readColorType == PNG_COLOR_TYPE_GRAY and bitDepth < 8:
    png_set_expand_gray_1_2_4_to_8 png

  if T is ColorA and png_get_valid(png, info, PNG_INFO_tRNS) != 0:
    png_set_tRNS_to_alpha png

  if hasAlpha:
    when T isnot ColorA:
      png_set_strip_alpha png
  else:
    when T is ColorA:
      png_set_filler(png, 0xFF, PNG_FILLER_AFTER)

  if readColorType == PNG_COLOR_TYPE_GRAY or
     readColorType == PNG_COLOR_TYPE_GRAY_ALPHA:
    png_set_gray_to_rgb png

  png_read_update_info png, info

  var
    r = initImage[when T is ColorA: ColorRGBAU else: ColorRGBU](
      png_get_image_width(png, info).int,
      png_get_image_height(png, info).int
    )
    rowPointers = newSeq[ptr cuchar](r.height)
    address = cast[int](addr r[0])

  let rowSize = r.width * sizeof colorType r

  for i in 0..rowPointers.high:
    rowPointers[i] = cast[ptr cuchar](address)
    address += rowSize

  png_read_image png, addr rowPointers[0]
  png_read_end png, info
  png_destroy_read_struct unsafeAddr png, unsafeAddr info, nil

  when T is ColorRGBUAny:
    return r
  else:
    return r.converted(T)

proc readPNG*[T: Color](file: File): Image[T] =
  readPNGImpl:
    png_init_io png, file

proc readPNG*[T: Color](data: openArray[char]): Image[T] =
  readPNGImpl:
    var reader = DataReader(start: unsafeAddr data[0], limit: data.len.uint)
    png_set_read_fn png, addr reader, pngReadString

proc loadPNG*[T: Color](path: string): Image[T] =
  let file = open(path, fmRead)
  defer: close file
  result = readPNG[T](file)

proc pngWriteBytes(png: ptr PngStruct, outBytes: ptr cuchar, count: csize_t) =
  var result = cast[ptr seq[byte]](png_get_io_ptr png)
  result[].setLen result[].len + count.int
  let address = addr result[][result[].len - count.int]
  copyMem address, outBytes, count

proc pngFlushBytes(png: ptr PngStruct) = discard

template writePNGImpl[T: Color](i: Image[T], compression: range[0..10], interlace: bool,
  filter: FilterKind, body: untyped): untyped =
  let
    png {.inject.} = png_create_write_struct(PNG_LIBPNG_VER_STRING, nil, errorHandler, warningHandler)
    info = png_create_info_struct(png)

  body

  png_set_IHDR(png, info, i.width.cuint, i.height.cuint, 8,
    when T is ColorA: PNG_COLOR_TYPE_RGB_ALPHA else: PNG_COLOR_TYPE_RGB,
    if interlace: PNG_INTERLACE_ADAM7 else: PNG_INTERLACE_NONE,
    PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT)

  png_set_filter png, PNG_FILTER_TYPE_DEFAULT, filter.cint
  png_set_compression_level png, compression.cint

  png_write_info png, info

  let img = i.converted(when T is ColorA: ColorRGBAU else: ColorRGBU)

  var
    rowPointers = newSeq[ptr cuchar](img.height)
    address = cast[int](unsafeAddr img[0])

  let rowSize = img.width * sizeof colorType img

  for n in 0..rowPointers.high:
    rowPointers[n] = cast[ptr cuchar](address)
    address += rowSize

  png_write_image png, addr rowPointers[0]
  png_write_end png, nil

  png_destroy_write_struct unsafeAddr png, unsafeAddr info, nil

proc writePNG*[T: Color](img: Image[T], file: File,
  compression: range[0..10] = 0, interlace = false, filter = fkNone) =
  img.writePNGImpl compression, interlace, filter:
    png_init_io png, file

proc writePNG*[T: Color](img: Image[T], compression: range[0..10] = 0,
  interlace = false, filter = fkNone): seq[byte] =
  img.writePNGImpl compression, interlace, filter:
    png_set_write_fn png, addr result, pngWriteBytes, pngFlushBytes

proc savePNG*[T: Color](i: Image[T], filename: string,
  compression: range[0..10] = 0, interlace = false, filter = fkNone) =
  let file = open(filename, fmWrite)
  defer: close file
  i.writePNG file, compression, interlace, filter
