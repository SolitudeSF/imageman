import sequtils, math, random, streams, endians
import stb_image/[read, write]
import colors

type
  Image* = object
    width*, height*: int
    data*: seq[Color]
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

func initImage*(w, h: Natural): Image =
  result.data = newSeq[Color](w * h)
  result.height = h
  result.width = w

func copyRegion*(image: Image, x, y, w, h: int): Image =
  result = initImage(w, h)
  for i in 0..<h:
    copyMem addr result[i * w], unsafeAddr image[x, i + y], w * sizeof(Color)

func copyRegion*(image: Image, r: Rect): Image =
  copyRegion(image, r.x, r.y, r.w, r.h)

func blit*(dest: var Image, src: Image, x, y: int) =
  for i in 0..<src.height:
    copyMem addr dest[x, i + y], unsafeAddr src[0, i], src.width * sizeof(Color)

func blit*(dest: var Image, src: Image, x, y: int, rect: Rect) =
  for i in 0..<rect.h:
    copyMem addr dest[x, i + y], unsafeAddr src[rect.x, i + rect.y], rect.w * sizeof(Color)

proc loadImage*(file: string): Image =
  var
    w, h, channels: int
    data = load(file, w, h, channels, RGBA)
  result = initImage(w, h)
  copyMem addr result.data[0], addr data[0], data.len

proc loadImageFromMemory*(buffer: seq[byte]): Image =
  var
    w, h, channels: int
    data = loadFromMemory(buffer, w, h, channels, RGBA)
  result = initImage(w, h)
  copyMem addr result.data[0], addr data[0], data.len

proc savePNG*(image: Image, file: string, strides = 0) =
  if not writePNG(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), strides):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveJPG*(image: Image, file: string, quality: range[1..100] = 95) =
  if not writeJPG(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), quality):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveBMP*(image: Image, file: string) =
  if not writeBMP(file, image.w, image.h, RGBA, cast[seq[byte]](image.data)):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveTGA*(image: Image, file: string, useRLE = true) =
  if not writeTGA(file, image.w, image.h, RGBA, cast[seq[byte]](image.data), useRLE):
    raise newException(IOError, "Failed to write the image to " & file)

proc writePNG*(image: Image, strides = 0): seq[byte] =
  write.writePNG(image.w, image.h, RGBA, cast[seq[byte]](image.data), strides)

proc writeJPG*(image: Image, quality: range[1..100] = 95): seq[byte] =
  write.writeJPG(image.w, image.h, RGBA, cast[seq[byte]](image.data), quality)

proc writeBMP*(image: Image): seq[byte] =
  write.writeBMP(image.w, image.h, RGBA, cast[seq[byte]](image.data))

proc writeTGA*(image: Image, useRLE = true): seq[byte] =
  write.writeTGA(image.w, image.h, RGBA, cast[seq[byte]](image.data), useRLE)
