import sequtils, math, random, streams, endians
import stb_image/[read, write]
import colors

type
 Image* = object
   width*, height*: int
   data*: seq[Color]
 Point* = tuple[x, y: int]

template w*(i: Image): int = i.width
template h*(i: Image): int = i.height
template `[]`*(i: Image, x, y: int): Color = i.data[x + y * i.w]
template `[]`*(i: Image, x: int): Color = i.data[x]
template `[]`*(i: Image, p: Point): Color = i.data[p.x + p.y * i.w]
template `[]=`*(i: var Image, x, y: int, c: Color) = i.data[x + y * i.w] = c
template `[]=`*(i: var Image, x: int, c: Color) = i.data[x] = c
template `[]=`*(i: var Image, p: Point, c: Color) = i.data[p.x + p.y * i.w] = c

func `in`*(p: Point, i: Image): bool = p.x >= 0 and p.y >= 0 and p.x < i.h and p.y < i.w

func newImage*(w, h: Natural): Image =
  result.data = newSeq[Color](w * h)
  result.height = h
  result.width = w

func copyRegion*(image: Image, x, y, w, h: int): Image =
  result = newImage(w, h)
  for i in 0..<h:
    let
      iw = i * w
      iyw = (i + y) * image.width
    for j in 0..<w:
      result[iw + j] = image[iyw + j + x]

proc loadImage*(file: string): Image =
  var
    w, h, channels: int
    data = load(file, w, h, channels, RGBA)
  result = newImage(w, h)
  copyMem addr result.data[0], addr data[0], data.len

proc loadImageFromMemory*(buffer: seq[byte]): Image =
  var
    w, h, channels: int
    data = loadFromMemory(buffer, w, h, channels, RGBA)
  result = newImage(w, h)
  copyMem addr result.data[0], addr data[0], data.len

proc savePNG*(image: Image, file: string, strides = 0) =
  if not writePNG(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), strides):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveJPG*(image: Image, file: string, quality: range[1..100] = 95) =
  if not writeJPG(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), quality):
    raise newException(IOError, "Failed to write the image to " & file)

proc writePNG*(image: Image, strides = 0): seq[byte] =
  write.writePNG(image.w, image.h, RGBA, cast[seq[byte]](image.data), strides)

proc writeJPG*(image: Image, quality: range[1..100] = 95): seq[byte] =
  write.writeJPG(image.w, image.h, RGBA, cast[seq[byte]](image.data), quality)
