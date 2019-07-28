import math, random

type
  Size = static int
  ColorComponent* = uint8 | float32
  ## Valid types for a color component
  ColorAny*[S: Size, C: ColorComponent] = array[S, C]
  ## Generic color
  Color8*[S: Size] = array[S, uint8]
  ## 8 bit component color
  ColorF*[S: Size] = array[S, float32]
  ## 32bit float component color
  ColorA*[C: ColorComponent] = array[4, C]
  ## Color with 4 components
  ColorRGB* = array[3, uint8]
  ## 8 bit RGB color
  ColorRGBA* = array[4, uint8]
  ## 8 bit RGBA color
  ColorRGBAF* = array[4, float32]
  ## RGBA color with floating components
  Color* = ColorRGBAF | ColorRGB | ColorRGBA
  ## Any concrete color type

template r*(c: Color): untyped = c[0]
template g*(c: Color): untyped = c[1]
template b*(c: Color): untyped = c[2]
template a*(c: ColorA): untyped = c[3]
template `r=`*(c: var Color, i: untyped) = c[0] = i
template `g=`*(c: var Color, i: untyped) = c[1] = i
template `b=`*(c: var Color, i: untyped) = c[2] = i
template `a=`*(c: var ColorA, i: untyped) = c[3] = i

template maxValue*(t: typedesc[Color]): untyped =
  when T is float32:
    1.0
  elif T is uint8:
    255

template componentType*(t: typedesc[Color]): untyped =
  when T is ColorRGBAF:
    float32
  else:
    uint8

template maxComponentValue*(t: typedesc[Color]): untyped =
  when T is ColorRGBAF:
    1.0'f32
  else:
    255'u8

template precise*[T: ColorComponent](t: T): float32 =
  when T is uint8:
    t.float32
  else:
    t

func toLinear*(c: uint8): float32 =
  c.float32 / 255

func toUint8*(c: float32): uint8 =
  uint8(c * 255)

func toRGB*(c: ColorRGBA): ColorRGB =
  copyMem addr result, unsafeAddr c, sizeof ColorRGB

func toRGBA*(c: ColorRGB): ColorRGBA =
  copyMem addr result, unsafeAddr c, sizeof ColorRGB
  result.a = 255

func toRGBAF*(c: ColorRGBA): ColorRGBAF =
  [c.r.toLinear, c.g.toLinear, c.b.toLinear, c.a.toLinear]

func toRGBAF*(c: ColorRGB): ColorRGBAF =
  [c.r.toLinear, c.g.toLinear, c.b.toLinear, 1.0]

func toRGBA*(c: ColorRGBAF): ColorRGBA =
  [c.r.toUint8, c.g.toUint8, c.b.toUint8, c.a.toUint8]

func toRGB*(c: ColorRGBAF): ColorRGB =
  [c.r.toUint8, c.g.toUint8, c.b.toUint8]

func blendColorValue*[T: ColorComponent](a, b: T, t: float32): T {.inline.} =
  T sqrt((1.0 - t) * a.precise * a.precise + t * b.precise * b.precise)

func `+`*[S, C](a, b: ColorAny[S, C]): ColorAny[S, C] =
  when S >= 3:
    result.r = blendColorValue(a.r, b.r, 0.3)
    result.g = blendColorValue(a.g, b.g, 0.3)
    result.b = blendColorValue(a.b, b.b, 0.3)
  elif S == 4:
    result.a = a.a

func `$`*(c: ColorRGBAF): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

func `$`*(c: ColorRGBA): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

func `$`*(c: ColorRGB): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ")"

func `~=`*(a, b: ColorRGBAF, e = 0.01'f32): bool =
  abs(a.r - b.r) < e and abs(a.g - b.g) < e and abs(a.b - b.b) < e

proc rand*[T: Color]: T =
  when T is ColorRGB:
    [uint8 rand(255), uint8 rand(255), uint8 rand(255)]
  elif T is ColorRGBA:
    [uint8 rand(255), uint8 rand(255), uint8 rand(255), uint rand(255)]
  elif T is ColorRGBAF:
    [rand(1.0), rand(1.0), rand(1.0), uint rand(1.0)]

func rand*[T: Color](r: var Rand): T =
  when T is ColorRGB:
    [uint8 r.rand(255), uint8 r.rand(255), uint8 r.rand(255)]
  elif T is ColorRGBA:
    [uint8 r.rand(255), uint8 r.rand(255), uint8 r.rand(255), uint r.rand(255)]
  elif T is ColorRGBAF:
    [r.rand(1.0), r.rand(1.0), r.rand(1.0), r.rand(1.0)]

func isGreyscale*(c: Color): bool =
  c.r == c.g and c.r == c.b

func interpolate*[T: Color](a, b: T, x: float32, L = 1.0): T =
  result.r = (T.componentType) (a.r.precise + x * (b.r.precise - a.r.precise) / L)
  result.g = (T.componentType) (a.g.precise + x * (b.g.precise - a.g.precise) / L)
  result.b = (T.componentType) (a.b.precise + x * (b.b.precise - a.b.precise) / L)
  when T isnot ColorRGB:
    result.a = (T.componentType) (a.a.precise + x * (b.a.precise - a.a.precise) / L)
