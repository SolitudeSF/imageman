import math, random

type
  ColorComponent* = uint8 | float32 | float64
  ColorRGBU* = object
    r*, g*, b*: uint8
  ColorRGBAU* = object
    r*, g*, b*, a*: uint8
  ColorRGBF* = object
    r*, g*, b*: float32
  ColorRGBAF* = object
    r*, g*, b*, a*: float32
  ColorRGBF64* = object
    r*, g*, b*: float64
  ColorRGBAF64* = object
    r*, g*, b*, a*: float64
  ColorHSL* = object
    h*, s*, l*: float32
  ColorHSLuv* = object
    h*, s*, l*: float64
  ColorHPLuv* = object
    h*, p*, l*: float64
  ColorRGBUAny* = ColorRGBU | ColorRGBAU
  ColorRGBFAny* = ColorRGBF | ColorRGBAF
  ColorRGBF64Any* = ColorRGBF64 | ColorRGBAF64
  ColorRGBAny* = ColorRGBUAny | ColorRGBFAny | ColorRGBF64Any
  ColorA* = ColorRGBAU | ColorRGBAF | ColorRGBAF64
  Color* = ColorRGBAny | ColorHSL | ColorHSLuv | ColorHPLuv
<<<<<<< HEAD
=======

>>>>>>> 57c4eda... Colors are now objects instead of arrays.

template componentType*(t: typedesc[Color]): typedesc =
  ## Returns component type of a given color type.
  when t is ColorRGBFAny | ColorHSL:
    float32
  elif t is ColorRGBF64Any | ColorHSLuv | ColorHPLuv:
    float64
  else:
    uint8

template iteratorImpl[T: Color](c: T): untyped =
  when T is ColorRGBAny:
    yield c.r
    yield c.g
    yield c.b
  elif T is (ColorHSL | ColorHSLuv):
    yield c.h
    yield c.s
    yield c.l
  elif T is ColorHPLuv:
    yield c.h
    yield c.p
    yield c.l
  when T is ColorA:
    yield c.a

iterator items*[T: Color](c: T): T.componentType = iteratorImpl[T](c)
iterator mitems*[T: Color](c: var T): var T.componentType = iteratorImpl[T](c)

template maxComponentValue*(t: typedesc[Color]): untyped =
  ## Returns maximum component value of a give color type.
  when t is ColorRGBFAny | ColorHSL:
    1.0'f32
  elif t is ColorRGBF64Any | ColorHSLuv | ColorHPLuv:
    1.0'f64
  else:
    255'u8

template precise*[T: ColorComponent](t: T): untyped =
  ## Converts component to float32 if it isn't.
  when T is uint8:
    t.float32
  else:
    t

template precise*[T: ColorComponent](t: typedesc[T]): typedesc =
  ## Converts component to float32 if it isn't.
  when T is uint8:
    float32
  else:
    t

func toLinear*(c: uint8): float32 =
  ## Converts 0..255 uint8 to 0..1 float32
  c.float32 / 255

func toUint8*(c: float32): uint8 =
  ## Converts 0..1 float32 to 0..255 uint8
  uint8(c * 255)

func to*[T: ColorRGBU](c: ColorRGBAU, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBU

func to*[T: ColorRGBAU](c: ColorRGBU, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBU
  result.a = 255

func to*[T: ColorRGBF](c: ColorRGBAF, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBF

func to*[T: ColorRGBAF](c: ColorRGBF, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBF
  result.a = 1.0

func to*[T: ColorRGBF](c: ColorRGBAny, t: typedesc[T]): T =
  ColorRGBF(r: c.r.toLinear, g:c.g.toLinear, b: c.b.toLinear)

func to*[T: ColorRGBU](c: ColorRGBFAny, t: typedesc[T]): T =
  ColorRGBU(r: c.r.toUint8, g: c.g.toUint8, b: c.b.toUint8)

func to*[T: ColorRGBAF](c: ColorRGBAU, t: typedesc[T]): T =
  ColorRGBAF(r: c.r.toLinear, g: c.g.toLinear, b: c.b.toLinear, a: c.a.toLinear)

func to*[T: ColorRGBAF](c: ColorRGBU, t: typedesc[T]): T =
  ColorRGBAF(r: c.r.toLinear, g: c.g.toLinear, b: c.b.toLinear, a: 1.0)

func to*[T: ColorRGBAU](c: ColorRGBF, t: typedesc[T]): T =
  ColorRGBAU(r: c.r.toUint8, g: c.g.toUint8, b: c.b.toUint8, a: 255)

func to*[T: ColorRGBAU](c: ColorRGBAF, t: typedesc[T]): T =
  ColorRGBAU(r: c.r.toUint8, g: c.g.toUint8, b: c.b.toUint8, a: c.a.toUint8)

func to*[T: ColorRGBF](c: ColorHSL, t: typedesc[T]): T =
  let a = c.s * min(c.l, 1 - c.l)

  template f(n: float32): float32 =
    let k = (n + c.h / 30) mod 12
    c.l - a * max(-1, min(1, min(k - 3, 9 - k)))

  ColorRGBF [f 0, f 8, f 4]

func to*[T: ColorHSL](c: ColorRGBF, t: typedesc[T]): T =
  let
    minC = min(c.r, min(c.g, c.b))
    maxC = max(c.r, max(c.g, c.b))
    chroma = maxC - minC

  result.l = (minC + maxC) / 2

  if chroma == 0:
    result.h = 0
  elif maxC == c.r:
    result.h = (c.g - c.b) / chroma
  elif maxC == c.g:
    result.h = 2 + (c.b - c.r) / chroma
  elif maxC == c.b:
    result.h = 4 + (c.r - c.g) / chroma

  result.h = min(result.h * 60, 360)
  if result.h < 0:
    result.h += 360

  if chroma != 0:
    result.s = chroma / (1 - abs(2 * result.l - 1))

func blendColorValue*[T: ColorComponent](a, b: T, t: float32): T {.inline.} =
  ## Blends two color with ratio.
  T sqrt((1.0 - t) * a.precise * a.precise + t * b.precise * b.precise)

func `+`*[T: Color](a, b: T): T =
  ## Blends two colors.
  result.r = blendColorValue(a.r, b.r, 0.3)
  result.g = blendColorValue(a.g, b.g, 0.3)
  result.b = blendColorValue(a.b, b.b, 0.3)
  when T is ColorA:
    result.a = a.a

func `~=`*[T: ColorRGBF64Any | ColorRGBFAny](a, b: T, e = T.componentType(0.01)): bool =
  ## Compares colors with given accuracy.
  abs(a.r - b.r) < e and abs(a.g - b.g) < e and abs(a.b - b.b) < e

proc rand(u: uint8): uint8 = uint8 u.int.rand
func rand(r: var Rand, u: uint8): uint8 = uint8 r.rand(u.int)

proc rand*[T: Color]: T =
  ## Returns random color.
  for c in result.mitems:
    c = typeof(c) rand(T.maxComponentValue)

func rand*[T: Color](r: var Rand): T =
  ## Returns random color.
  for c in result.mitems:
    c = typeof(c) r.rand(T.maxComponentValue)

func isGreyscale*(c: ColorRGBAny): bool =
  ## Checks if color is grayscale (all color components are equal).
  c.r == c.g and c.r == c.b

func interpolate*[T: ColorRGBAny](a, b: T, x: float32, L = 1.0): T =
  ## Returns linearly interpolated color value.
  result.r = (T.componentType) (a.r.precise + x * (b.r.precise - a.r.precise) / L)
  result.g = (T.componentType) (a.g.precise + x * (b.g.precise - a.g.precise) / L)
  result.b = (T.componentType) (a.b.precise + x * (b.b.precise - a.b.precise) / L)
  when T is ColorA:
    result.a = (T.componentType) (a.a.precise + x * (b.a.precise - a.a.precise) / L)
