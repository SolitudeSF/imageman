import sequtils, math, random, streams, endians
import stb_image/[read, write]
import colors

type
 Image* = object
   w*, h*: int
   data*: seq[Color]
 Point* = tuple[x, y: int]

func isInside*(p: Point, i: Image): bool = p.x >= 0 and p.y >= 0 and p.x < i.h and p.y < i.w

template `[]`*(i: Image, x, y: int): Color = i.data[x + y * i.w]
template `[]`*(i: Image, x: int): Color = i.data[x]
template `[]`*(i: Image, p: Point): Color = i.data[p.x + p.y * i.w]
template `[]=`*(i: var Image, x, y: int, c: Color) = i.data[x + y * i.w] = c
template `[]=`*(i: var Image, x: int, c: Color) = i.data[x] = c
template `[]=`*(i: var Image, p: Point, c: Color) = i.data[p.x + p.y * i.w] = c

func newImage*(w, h: Natural): Image =
  result.data = newSeq[Color](w * h)
  result.h = h.int
  result.w = w.int

proc loadImage*(file: string): Image =
  var
    w, h, channels: int
    data = load(file, w, h, channels, RGBA)
  result = newImage(w, h)
  copyMem addr result.data[0], addr data[0], data.len

proc savePNG*(image: Image, file: string, strides = 0) =
  if not writePNG(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), strides):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveJPG*(image: Image, file: string, quality: range[1..100] = 95) =
  if not writeJPG(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), quality):
    raise newException(IOError, "Failed to write the image to " & file)
