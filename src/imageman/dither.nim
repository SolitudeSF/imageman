import ./images, ./colors, ./filters
import macros

func addError[T: Color](i: var Image[T], x, y: int, factor, r, g, b: float32) {.inline.} =
  if not (x < 0 or y >= i.h or x >= i.w):
    let idx = x + y * i.w
    i[idx].r = (T.componentType) (i[idx].r.precise + r * factor)
    i[idx].g = (T.componentType) (i[idx].g.precise + g * factor)
    i[idx].b = (T.componentType) (i[idx].b.precise + b * factor)

macro addErrors(image: var Image, x, y: int, r, g, b, denominator: float32, coeffs: array): untyped =
  proc offset(i, o: NimNode): NimNode =
    result = if o.intVal > 0:
      nnkInfix.newTree(ident"+", i, o)
    elif o.intVal < 0:
      nnkInfix.newTree(ident"-", i, o.intVal.abs.int.newLit)
    else:
      i

  result = newStmtList()

  for i in countup(0, coeffs.len - 1, 3):
    result.add newCall(
      bindSym"addError", image,
      offset(x, coeffs[i]),
      offset(y, coeffs[i + 1]),
      nnkInfix.newTree(ident"/", coeffs[i + 2], denominator),
      r, g, b
    )

func twoDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 4.0, [
    1, 0, 2,
    0, 1, 1,
    1, 1, 1
  ]

func floydsteinDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 16.0, [
    1, 0, 7,
    -1,1, 3,
    0, 1, 5,
    1, 1, 1
  ]

func atkinsonDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 8.0, [
    1, 0, 1,
    2, 0, 1,
    -1,1, 1,
    0, 1, 1,
    1, 1, 1,
    0, 2, 1
  ]

func burkeDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 42.0, [
    1, 0, 8,
    2, 0, 4,
    -2,1, 2,
    -1,1, 4,
    0, 1, 8,
    1, 1, 4,
    2, 1, 2
  ]

func sierraDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 32.0, [
    1, 0, 5,
    2, 0, 3,
    -2,1, 2,
    -1,1, 3,
    0, 1, 5,
    1, 1, 4,
    2, 1, 2,
    -1,2, 2,
    0, 2, 3,
    1, 2, 2
  ]

func sierra2Dist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 16.0, [
    1, 0, 4,
    2, 0, 3,
    -2,1, 1,
    -1,1, 2,
    0, 1, 3,
    1, 1, 2,
    2, 1, 1
  ]

func sierraLiteDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 4.0, [
    1, 0, 2,
    -1,1, 1,
    0, 1, 1
  ]

func jarvisDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 48.0, [
    1, 0, 7,
    2, 0, 5,
    -2,1, 3,
    -1,1, 5,
    0, 1, 7,
    1, 1, 5,
    2, 1, 3,
    -2,2, 1,
    -1,2, 3,
    0, 2, 5,
    1, 2, 3,
    2, 2, 1
  ]

func stuckiDist*(i: var Image, x, y: int, r, g, b: float32) =
  i.addErrors x, y, r, g, b, 42.0, [
    1, 0, 8,
    2, 0, 4,
    -2,1, 2,
    -1,1, 4,
    0, 1, 8,
    1, 1, 4,
    2, 1, 2,
    -2,2, 1,
    -1,2, 2,
    0, 2, 4,
    1, 2, 2,
    2, 2, 1
  ]

template dither*[T: ColorRGBAny](i: var Image[T], dist) =
  for y in 0..<i.h:
    let yw = y * i.w
    for x in 0..<i.w:
      let idx = x + yw
      let prev = i[idx]
      i[idx].quantize 1
      i.dist(x, y, prev.r.precise - i[idx].r.precise,
                   prev.g.precise - i[idx].g.precise,
                   prev.b.precise - i[idx].b.precise)

template dithered*(i: Image, dist): Image =
  var r = i
  r.dither dist
  r
