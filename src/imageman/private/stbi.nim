import ../colors
import imagetype
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

proc readImage*[T: Color](buffer: seq[byte]): Image[T] =
  ## Reads image with specified color mode from a sequence of bytes.
  readImageImpl width, height, channels:
    loadFromMemory(buffer, width, height, channels, T.toColorMode)

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
