import sequtils, math, random, streams, endians
import stb_image/[read, write]
import colors
export ColorRGB, ColorRGBA, ColorRGBAF

type
  Image*[T: Color] = object
    width*, height*: int
    data*: seq[T]
  Point* = tuple[x, y: int]
  Rect* = object
    x*, y*, w*, h*: int

func contains*(i: Image, p: Point): bool =
  p.x >= 0 and p.y >= 0 and p.x < i.height and p.y < i.width

func contains*(i: Image, x, y: int): bool =
  x >= 0 and y >= 0 and x < i.height and y < i.width

template `in`*(p: Point, i: Image): bool = i.contains p

template w*(i: Image): int = i.width
template h*(i: Image): int = i.height

template `[]`*(i: Image, x, y: int): Color =
  when defined(imagemanSafe):
    if i.contains(x, y): i.data[x + y * i.w]
  else:
    i.data[x + y * i.w]

template `[]`*(i: Image, x: int): Color =
  when defined(imagemanSafe):
    if x < i.data.len: i.data[x]
  else:
    i.data[x]

template `[]`*(i: Image, p: Point): Color =
  when defined(imagemanSafe):
    if p in i: i.data[p.x + p.y * i.w]
  else:
    i.data[p.x + p.y * i.w]

template `[]=`*(i: var Image, x, y: int, c: Color) =
  when defined(imagemanSafe):
    if i.contains(x, y): i.data[x + y * i.w] = c
  else:
    i.data[x + y * i.w] = c

template `[]=`*(i: var Image, x: int, c: Color) =
  when defined(imagemanSafe):
    if x < i.data.len: i.data[x] = c
  else:
    i.data[x] = c

template `[]=`*(i: var Image, p: Point, c: Color) =
  when defined(imagemanSafe):
    if p in i: i.data[p.x + p.y * i.w] = c
  else:
    i.data[p.x + p.y * i.w] = c

func initRect*(x, y, w, h: int): Rect = Rect(x: x, y: y, w: w, h: h)

func toRect*(a, b: Point): Rect = initRect(a.x, a.y, b.x - a.x, b.y - a.y)

func initImage*[T: Color](w, h: Natural): Image[T] =
  Image[T](data: newSeq[T](w * h), height: h, width: w)

func copyRegion*[T: Color](image: Image[T], x, y, w, h: int): Image[T] =
  result = initImage[T](w, h)
  for i in 0..<h:
    copyMem addr result[i * w], unsafeAddr image[x, i + y], w * sizeof(T)

func copyRegion*[T: Color](image: Image[T], r: Rect): Image[T] =
  copyRegion(image, r.x, r.y, r.w, r.h)

func blit*[T: Color](dest: var Image[T], src: Image, x, y: int) =
  for i in 0..<src.height:
    copyMem addr dest[x, i + y], unsafeAddr src[0, i], src.width * sizeof(T)

func blit*[T: Color](dest: var Image[T], src: Image, x, y: int, rect: Rect) =
  for i in 0..<rect.h:
    copyMem addr dest[x, i + y], unsafeAddr src[rect.x, i + rect.y], rect.w * sizeof(T)

template colorToColorMode(t: typedesc[Color]): untyped =
  when t is ColorRGB:
    RGB
  elif t is ColorRGBA:
    RGBA
  elif t is ColorRGBAF:
    RGBA

template importData[T: Color](r: var seq[T], s: seq[byte]) =
  when T is ColorRGBAF:
    for i in 0..r.high:
      r[i][0] = s[i * 4].toLinear
      r[i][1] = s[i * 4 + 1].toLinear
      r[i][2] = s[i * 4 + 2].toLinear
      r[i][3] = s[i * 4 + 3].toLinear
  else:
    copyMem addr r[0], unsafeAddr s[0], s.len

template toExportData[T: Color](s: seq[T]): seq[byte] =
  when T is ColorRGBAF:
    var r = newSeq[byte](s.len * 4)
    for i in 0..s.high:
      r[i * 4]     = s[i][0].toUint8
      r[i * 4 + 1] = s[i][1].toUint8
      r[i * 4 + 2] = s[i][2].toUint8
      r[i * 4 + 3] = s[i][3].toUint8
    r
  else:
    cast[seq[byte]](s)

proc loadImage*[T: Color](file: string): Image[T] =
  var
    w, h, channels: int
    data = load(file, w, h, channels, T.colorToColorMode)
  result = initImage[T](w, h)
  result.data.importData data

proc loadImageFromMemory*[T: Color](buffer: seq[byte]): Image[T] =
  var
    w, h, channels: int
    data = loadFromMemory(buffer, w, h, channels, T.colorToColorMode)
  result = initImage[T](w, h)
  result.data.importData data

proc savePNG*[T: Color](image: Image[T], file: string, strides = 0) =
  if not writePNG(file, image.w, image.h, T.colorToColorMode, image.data.toExportData, strides):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveJPG*[T: Color](image: Image[T], file: string, quality: range[1..100] = 95) =
  if not writeJPG(file, image.w, image.h, T.colorToColorMode, image.data.toExportData, quality):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveBMP*[T: Color](image: Image[T], file: string) =
  if not writeBMP(file, image.w, image.h, T.colorToColorMode, image.data.toExportData):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveTGA*[T: Color](image: Image[T], file: string, useRLE = true) =
  if not writeTGA(file, image.w, image.h, T.colorToColorMode, image.data.toExportData, useRLE):
    raise newException(IOError, "Failed to write the image to " & file)

proc writePNG*[T: Color](image: Image[T], strides = 0): seq[byte] =
  write.writePNG(image.w, image.h, T.colorToColorMode, image.data.toExportData, strides)

proc writeJPG*[T: Color](image: Image[T], quality: range[1..100] = 95): seq[byte] =
  write.writeJPG(image.w, image.h, T.colorToColorMode, image.data.toExportData, quality)

proc writeBMP*[T: Color](image: Image[T]): seq[byte] =
  write.writeBMP(image.w, image.h, T.colorToColorMode, image.data.toExportData)

proc writeTGA*[T: Color](image: Image[T], useRLE = true): seq[byte] =
  write.writeTGA(image.w, image.h, T.colorToColorMode, image.data.toExportData, useRLE)
