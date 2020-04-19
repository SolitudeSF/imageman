import math, random, typetraits

type
  ColorComponent* = uint8 | float32
  ColorRGBU* = distinct array[3, uint8]
  ColorRGBAU* = distinct array[4, uint8]
  ColorRGBF* = distinct array[3, float32]
  ColorRGBAF* = distinct array[4, float32]
  ColorHSL* = distinct array[3, float32]
  ColorRGBUAny* = ColorRGBU | ColorRGBAU
  ColorRGBFAny* = ColorRGBF | ColorRGBAF
  ColorRGBAny* = ColorRGBUAny | ColorRGBFAny
  ColorA* = ColorRGBAU | ColorRGBAF
  Color* = ColorRGBAny | ColorHSL

template `[]`*[T: Color](c: T, n: Ordinal): auto = distinctBase(c)[n]
template `[]=`*[T: Color](c: var T, n: Natural, v) = distinctBase(c)[n] = v
template len*(c: typedesc[Color]): int = distinctBase(c).len
template len*(c: Color): int = distinctBase(c).len
template high*(c: typedesc[Color]): int = distinctBase(c).high
template high*(c: Color): int = distinctBase(c).high
template `==`*[T: Color](x, y: T): bool = distinctBase(x) == distinctBase(y)

template r*(c: ColorRGBAny): untyped = c[0]
template g*(c: ColorRGBAny): untyped = c[1]
template b*(c: ColorRGBAny): untyped = c[2]
template a*(c: ColorA): untyped = c[3]
template `r=`*(c: var ColorRGBAny, i: untyped) = c[0] = i
template `g=`*(c: var ColorRGBAny, i: untyped) = c[1] = i
template `b=`*(c: var ColorRGBAny, i: untyped) = c[2] = i
template `a=`*(c: var ColorA, i: untyped) = c[3] = i
template h*(c: ColorHSL): float32 = c[0]
template s*(c: ColorHSL): float32 = c[1]
template l*(c: ColorHSL): float32 = c[2]
template `h=`*(c: var ColorHSL, i: float32) = c[0] = i
template `s=`*(c: var ColorHSL, i: float32) = c[1] = i
template `l=`*(c: var ColorHSL, i: float32) = c[2] = i

template componentType*(t: typedesc[Color]): typedesc =
  ## Returns component type of a given color type.
  when t is ColorRGBFAny:
    float32
  else:
    uint8

template maxComponentValue*(t: typedesc[Color]): untyped =
  ## Returns maximum component value of a give color type.
  when t is ColorRGBFAny:
    1.0'f32
  else:
    255'u8

template precise*[T: ColorComponent](t: T): float32 =
  ## Converts component to float32 if it isn't.
  when T is uint8:
    t.float32
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
  ColorRGBF [c.r.toLinear, c.g.toLinear, c.b.toLinear]

func to*[T: ColorRGBU](c: ColorRGBFAny, t: typedesc[T]): T =
  ColorRGBU [c.r.toUint8, c.g.toUint8, c.b.toUint8]

func to*[T: ColorRGBAF](c: ColorRGBAU, t: typedesc[T]): T =
  ColorRGBAF [c.r.toLinear, c.g.toLinear, c.b.toLinear, c.a.toLinear]

func to*[T: ColorRGBAF](c: ColorRGBU, t: typedesc[T]): T =
  ColorRGBAF [c.r.toLinear, c.g.toLinear, c.b.toLinear, 1.0]

func to*[T: ColorRGBAU](c: ColorRGBF, t: typedesc[T]): T =
  ColorRGBAU [c.r.toUint8, c.g.toUint8, c.b.toUint8, 255]

func to*[T: ColorRGBAU](c: ColorRGBAF, t: typedesc[T]): T =
  ColorRGBAU [c.r.toUint8, c.g.toUint8, c.b.toUint8, c.a.toUint8]

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

func `$`*(c: ColorA): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

func `$`*(c: ColorRGBU | ColorRGBF): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ")"

func `$`*(c: ColorHSL): string =
  "(h: " & $c.h & ", s: " & $c.s & ", l: " & $c.l & ")"

func `~=`*(a, b: ColorRGBAF, e = 0.01'f32): bool =
  ## Compares colors with given accuracy.
  abs(a.r - b.r) < e and abs(a.g - b.g) < e and abs(a.b - b.b) < e

proc rand*[T: Color]: T =
  ## Returns random color.
  T (when T is ColorRGBU:
    [uint8 rand(255), uint8 rand(255), uint8 rand(255)]
  elif T is ColorRGBAU:
    [uint8 rand(255), uint8 rand(255), uint8 rand(255), uint rand(255)]
  elif T is ColorRGBF:
    [rand(1.0), rand(1.0), rand(1.0)]
  elif T is ColorRGBAF:
    [rand(1.0), rand(1.0), rand(1.0), uint rand(1.0)]
  )

func rand*[T: Color](r: var Rand): T =
  ## Returns random color.
  T (when T is ColorRGBU:
    [uint8 r.rand(255), uint8 r.rand(255), uint8 r.rand(255)]
  elif T is ColorRGBAU:
    [uint8 r.rand(255), uint8 r.rand(255), uint8 r.rand(255), uint r.rand(255)]
  elif T is ColorRGBF:
    [r.rand(1.0), r.rand(1.0), r.rand(1.0)]
  elif T is ColorRGBAF:
    [r.rand(1.0), r.rand(1.0), r.rand(1.0), r.rand(1.0)]
  )

func isGreyscale*(c: Color): bool =
  ## Checks if color is grayscale (all color components are equal).
  c.r == c.g and c.r == c.b

func interpolate*[T: Color](a, b: T, x: float32, L = 1.0): T =
  ## Returns linearly interpolated color value.
  result.r = (T.componentType) (a.r.precise + x * (b.r.precise - a.r.precise) / L)
  result.g = (T.componentType) (a.g.precise + x * (b.g.precise - a.g.precise) / L)
  result.b = (T.componentType) (a.b.precise + x * (b.b.precise - a.b.precise) / L)
  when T is ColorA:
    result.a = (T.componentType) (a.a.precise + x * (b.a.precise - a.a.precise) / L)
