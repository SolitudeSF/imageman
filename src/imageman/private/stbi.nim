import ../colors, ./imagetype
import stb_image/[read, write]

template toColorMode(t: typedesc[Color]): untyped =
  when t is ColorA: RGBA else: RGB

template importData(w, h: int, s: seq[byte]): untyped =
  var r = initImage[when T is ColorA: ColorRGBAU else: ColorRGBU](w, h)
  copyMem addr r[0], unsafeAddr s[0], s.len
  return (when T is r.colorType: r else: r.converted(T))

template toExportData[T: Color](i: Image[T]): seq[byte] =
  when T is ColorRGBUAny:
    cast[seq[byte]](i.data)
  elif T is ColorA:
    cast[seq[byte]](i.converted(ColorRGBAU).data)
  else:
    cast[seq[byte]](i.converted(ColorRGBU).data)

template readImageImpl(w, h, channels, io: untyped): untyped =
  var
    w, h, channels: int
    data = try:
      io
    except STBIException as e:
      raise newException(IOError, e.msg)
  importData w, h, data

# Workaround for missing openArray overload
when defined(windows) and defined(vcc):
  {.pragma: stbcall, stdcall.}
else:
  {.pragma: stbcall, cdecl.}

proc stbi_image_free(retval_from_stbi_load: pointer) {.importc: "stbi_image_free", stbcall.}
proc stbi_load_from_memory(buffer: ptr cuchar; len: cint; x, y, channels_in_file: var cint;
  desired_channels: cint): ptr cuchar {.importc: "stbi_load_from_memory", stbcall.}

proc loadFromMemory*(data: openArray[char]; x, y, channels_in_file: var int; desired_channels: int): seq[byte] =
  var
    castedBuffer = cast[ptr cuchar](data[0].unsafeAddr)
    w, h, components: cint
  let data = stbi_load_from_memory(castedBuffer, data.len.cint, w, h, components, desired_channels.cint)
  if data == nil:
    raise newException(STBIException, failureReason())
  x = w.int
  y = h.int
  channels_in_file = components.int
  let actualChannels = if desired_channels > 0: desired_channels else: components.int
  result = newSeq[byte](x * y * actualChannels)
  copyMem(result[0].addr, data, result.len)
  stbi_image_free(data)

proc readImage*[T: Color](data: openArray[char]): Image[T] =
  ## Reads image with specified color mode from a sequence of bytes.
  readImageImpl width, height, channels:
    loadFromMemory(data, width, height, channels, T.toColorMode)

proc readImage*[T: Color](file: File): Image[T] =
  ## Reads image with specified color mode from a file
  readImageImpl width, height, channels:
    loadFromFile(file, width, height, channels, T.toColorMode)

proc loadImage*[T: Color](file: string): Image[T] =
  ## Reads image with specified color mode from a file with provided filename
  readImageImpl width, height, channels:
    load(file, width, height, channels, T.toColorMode)

proc savePNG*[T: Color](image: Image[T], file: string) =
  ## Saves the image in `png` format to a file.
  if not write.writePNG(file, image.width, image.height, T.toColorMode, image.toExportData):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveJPEG*[T: Color](image: Image[T], file: string, quality: range[1..100] = 95) =
  ## Saves the image in `jpg` format to a file.
  ## Optional quality parameter can be specified in range 1..100.
  if not write.writeJPG(file, image.width, image.height, T.toColorMode, image.toExportData, quality):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveBMP*[T: Color](image: Image[T], file: string) =
  ## Saves the image in `bmp` format to a file.
  if not write.writeBMP(file, image.width, image.height, T.toColorMode, image.toExportData):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveTGA*[T: Color](image: Image[T], file: string, useRLE = true) =
  ## Saves the image in `tga` format to a file.
  ## `useRLE` parameter can be specified to enable/disable RLE compressed data.
  if not write.writeTGA(file, image.width, image.height, T.toColorMode, image.toExportData, useRLE):
    raise newException(IOError, "Failed to write the image to " & file)

proc writePNG*[T: Color](image: Image[T]): seq[byte] =
  ## Converts image to a png data.
  write.writePNG(image.width, image.height, T.toColorMode, image.toExportData)

proc writeJPEG*[T: Color](image: Image[T], quality: range[1..100] = 95): seq[byte] =
  ## Converts image to a jpg data.
  write.writeJPG(image.width, image.height, T.toColorMode, image.toExportData, quality)

proc writeBMP*[T: Color](image: Image[T]): seq[byte] =
  ## Converts image to a bmp data.
  write.writeBMP(image.width, image.height, T.toColorMode, image.toExportData)

proc writeTGA*[T: Color](image: Image[T], useRLE = true): seq[byte] =
  ## Converts image to a tga data.
  write.writeTGA(image.width, image.height, T.toColorMode, image.toExportData, useRLE)
