import images, colors, filters
import math, sequtils

proc addError(i: var Image, x, y: int, factor: float, r, g, b: float) =
  if not (x < 0 or y >= i.h or x >= i.w):
    i[x, y].r = uint8(i[x, y].r.float + r * factor)
    i[x, y].g = uint8(i[x, y].g.float + g * factor)
    i[x, y].b = uint8(i[x, y].b.float + b * factor)

proc twoDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 2/4.0, r, g, b)
  i.addError(x    , y + 1, 1/4.0, r, g, b)
  i.addError(x + 1, y + 1, 1/4.0, r, g, b)

proc floydsteinDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 7/16.0, r, g, b)
  i.addError(x - 1, y + 1, 3/16.0, r, g, b)
  i.addError(x    , y + 1, 5/16.0, r, g, b)
  i.addError(x + 1, y + 1, 1/16.0, r, g, b)

proc atkinsonDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 1/8.0, r, g, b)
  i.addError(x + 2, y    , 1/8.0, r, g, b)
  i.addError(x - 1, y + 1, 1/8.0, r, g, b)
  i.addError(x    , y + 1, 1/8.0, r, g, b)
  i.addError(x + 1, y + 1, 1/8.0, r, g, b)
  i.addError(x    , y + 2, 1/8.0, r, g, b)

proc burkeDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 8/42.0, r, g, b)
  i.addError(x + 2, y    , 4/42.0, r, g, b)
  i.addError(x - 2, y + 1, 2/42.0, r, g, b)
  i.addError(x - 1, y + 1, 4/42.0, r, g, b)
  i.addError(x    , y + 1, 8/42.0, r, g, b)
  i.addError(x + 1, y + 1, 4/42.0, r, g, b)
  i.addError(x + 2, y + 1, 2/42.0, r, g, b)

proc sierraDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 5/32.0, r, g, b)
  i.addError(x + 2, y    , 3/32.0, r, g, b)
  i.addError(x - 2, y + 1, 2/32.0, r, g, b)
  i.addError(x - 1, y + 1, 3/32.0, r, g, b)
  i.addError(x    , y + 1, 5/32.0, r, g, b)
  i.addError(x + 1, y + 1, 4/32.0, r, g, b)
  i.addError(x + 2, y + 1, 2/32.0, r, g, b)
  i.addError(x - 1, y + 2, 2/32.0, r, g, b)
  i.addError(x    , y + 2, 3/32.0, r, g, b)
  i.addError(x + 1, y + 2, 2/32.0, r, g, b)

proc sierra2Dist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 4/16.0, r, g, b)
  i.addError(x + 2, y    , 3/16.0, r, g, b)
  i.addError(x - 2, y + 1, 1/16.0, r, g, b)
  i.addError(x - 1, y + 1, 2/16.0, r, g, b)
  i.addError(x    , y + 1, 3/16.0, r, g, b)
  i.addError(x + 1, y + 1, 2/16.0, r, g, b)
  i.addError(x + 2, y + 1, 1/16.0, r, g, b)

proc sierraLiteDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 2/4.0, r, g, b)
  i.addError(x - 1, y + 1, 1/4.0, r, g, b)
  i.addError(x    , y + 1, 1/4.0, r, g, b)

proc jarvisDist(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 7/48.0, r, g, b)
  i.addError(x + 2, y    , 5/48.0, r, g, b)
  i.addError(x - 2, y + 1, 3/48.0, r, g, b)
  i.addError(x - 1, y + 1, 5/48.0, r, g, b)
  i.addError(x    , y + 1, 7/48.0, r, g, b)
  i.addError(x + 1, y + 1, 5/48.0, r, g, b)
  i.addError(x + 2, y + 1, 3/48.0, r, g, b)
  i.addError(x - 2, y + 2, 1/48.0, r, g, b)
  i.addError(x - 1, y + 2, 3/48.0, r, g, b)
  i.addError(x    , y + 2, 5/48.0, r, g, b)
  i.addError(x + 1, y + 2, 3/48.0, r, g, b)
  i.addError(x + 2, y + 2, 1/48.0, r, g, b)

proc stuckiDist(i: var Image, x,y: int, r, g, b: float) =
  i.addError(x + 1, y    , 8/42.0, r, g, b)
  i.addError(x + 2, y    , 4/42.0, r, g, b)
  i.addError(x - 2, y + 1, 2/42.0, r, g, b)
  i.addError(x - 1, y + 1, 4/42.0, r, g, b)
  i.addError(x    , y + 1, 8/42.0, r, g, b)
  i.addError(x + 1, y + 1, 4/42.0, r, g, b)
  i.addError(x + 2, y + 1, 2/42.0, r, g, b)
  i.addError(x - 2, y + 2, 1/42.0, r, g, b)
  i.addError(x - 1, y + 2, 2/42.0, r, g, b)
  i.addError(x    , y + 2, 4/42.0, r, g, b)
  i.addError(x + 1, y + 2, 2/42.0, r, g, b)
  i.addError(x + 2, y + 2, 1/42.0, r, g, b)

proc dither(image: var Image, dist: proc(i: var Image, x, y: int, r, g, b: float)) =
  for y in 0..<image.h:
    for x in 0..<image.w:
      let prev = image[x, y]
      image[x, y].quantize 1'u8
      image.dist(x, y, prev.r.float - image[x, y].r.float,
                       prev.g.float - image[x, y].g.float,
                       prev.b.float - image[x, y].b.float)
