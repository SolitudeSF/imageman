import images, colors, filters

func addError*(i: var Image, x, y: int, factor: float, r, g, b: float) =
  if not (x < 0 or y >= i.h or x >= i.w):
    let idx = x + y * i.w
    i[idx].r = uint8(i[idx].r.float + r * factor)
    i[idx].g = uint8(i[idx].g.float + g * factor)
    i[idx].b = uint8(i[idx].b.float + b * factor)

func twoDist*(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 2/4.0, r, g, b)
  i.addError(x    , y + 1, 1/4.0, r, g, b)
  i.addError(x + 1, y + 1, 1/4.0, r, g, b)

func floydsteinDist*(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 7/16.0, r, g, b)
  i.addError(x - 1, y + 1, 3/16.0, r, g, b)
  i.addError(x    , y + 1, 5/16.0, r, g, b)
  i.addError(x + 1, y + 1, 1/16.0, r, g, b)

func atkinsonDist*(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 1/8.0, r, g, b)
  i.addError(x + 2, y    , 1/8.0, r, g, b)
  i.addError(x - 1, y + 1, 1/8.0, r, g, b)
  i.addError(x    , y + 1, 1/8.0, r, g, b)
  i.addError(x + 1, y + 1, 1/8.0, r, g, b)
  i.addError(x    , y + 2, 1/8.0, r, g, b)

func burkeDist*(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 8/42.0, r, g, b)
  i.addError(x + 2, y    , 4/42.0, r, g, b)
  i.addError(x - 2, y + 1, 2/42.0, r, g, b)
  i.addError(x - 1, y + 1, 4/42.0, r, g, b)
  i.addError(x    , y + 1, 8/42.0, r, g, b)
  i.addError(x + 1, y + 1, 4/42.0, r, g, b)
  i.addError(x + 2, y + 1, 2/42.0, r, g, b)

func sierraDist*(i: var Image, x, y: int, r, g, b: float) =
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

func sierra2Dist*(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 4/16.0, r, g, b)
  i.addError(x + 2, y    , 3/16.0, r, g, b)
  i.addError(x - 2, y + 1, 1/16.0, r, g, b)
  i.addError(x - 1, y + 1, 2/16.0, r, g, b)
  i.addError(x    , y + 1, 3/16.0, r, g, b)
  i.addError(x + 1, y + 1, 2/16.0, r, g, b)
  i.addError(x + 2, y + 1, 1/16.0, r, g, b)

func sierraLiteDist*(i: var Image, x, y: int, r, g, b: float) =
  i.addError(x + 1, y    , 2/4.0, r, g, b)
  i.addError(x - 1, y + 1, 1/4.0, r, g, b)
  i.addError(x    , y + 1, 1/4.0, r, g, b)

func jarvisDist*(i: var Image, x, y: int, r, g, b: float) =
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

func stuckiDist*(i: var Image, x, y: int, r, g, b: float) =
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

template dither*(i: var Image, dist) =
  for y in 0..<i.h:
    let yw = y * i.w
    for x in 0..<i.w:
      let idx = x + yw
      let prev = i[idx]
      i[idx].quantize 1'u8
      i.dist(x, y, prev[0].float - i[idx][0].float,
                   prev[1].float - i[idx][1].float,
                   prev[2].float - i[idx][2].float)

template dithered*(i: Image, dist): Image =
  var r = i
  r.dither dist
  r
