import math, random

type
  ColorRGB* = array[3, uint8]
  ColorRGBA* = array[4, uint8]
  Color* = ColorRGB | ColorRGBA

const
  white*       = [255'u8, 255'u8, 255'u8]
  black*       = [0'u8  , 0'u8  , 0'u8  ]
  red*         = [255'u8, 0'u8  , 0'u8  ]
  green*       = [0'u8  , 255'u8, 0'u8  ]
  blue*        = [0'u8  , 0'u8  , 255'u8]
  yellow*      = [255'u8, 255'u8, 0'u8  ]
  magenta*     = [255'u8, 0'u8  , 255'u8]
  transparent* = [255'u8, 255'u8, 255'u8, 0'u8  ]

template r*(c: Color): uint8 = c[0]
template g*(c: Color): uint8 = c[1]
template b*(c: Color): uint8 = c[2]
template a*(c: ColorRGBA): uint8 = c[3]
template `r=`*(c: var Color, i: uint8) = c[0] = i
template `g=`*(c: var Color, i: uint8) = c[1] = i
template `b=`*(c: var Color, i: uint8) = c[2] = i
template `a=`*(c: var ColorRGBA, i: uint8) = c[3] = i

func `all=`*(c: var Color, i: uint8) =
  c.r = i
  c.g = i
  c.b = i

func toColorRGB*(c: ColorRGBA): ColorRGB =
  copyMem addr result, unsafeAddr c, sizeof ColorRGB

func toColorRGBA*(c: ColorRGB): ColorRGBA =
  copyMem addr result, unsafeAddr c, sizeof ColorRGB

func blendColorValue*(a, b: uint8, t: float): uint8 {.inline.} =
  uint8 sqrt((1.0 - t) * a.float * a.float + t * b.float * b.float)

func `+`*[T: Color](a, b: T): T =
  when T is ColorRGB:
    [blendColorValue(a.r, b.r, 0.3),
     blendColorValue(a.g, b.g, 0.3),
     blendColorValue(a.b, b.b, 0.3)]
  else:
    [blendColorValue(a.r, b.r, 0.3),
     blendColorValue(a.g, b.g, 0.3),
     blendColorValue(a.b, b.b, 0.3),
     a.a]

func `$`*(c: ColorRGBA): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

func `$`*(c: ColorRGB): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ")"

proc randomColor*: ColorRGB = [uint8 rand(255),
                               uint8 rand(255),
                               uint8 rand(255)]

func randomColor*(r: var Rand): ColorRGB = [uint8 r.rand(255),
                                            uint8 r.rand(255),
                                            uint8 r.rand(255)]

func isGreyscale*(c: Color): bool =
  c.r == c.g and c.r == c.b

func interpolate*[T: Color](a, b: T, x: float, L = 1.0): T =
  result.r = uint8(a.r.float + x * (b.r.float - a.r.float) / L)
  result.g = uint8(a.g.float + x * (b.g.float - a.g.float) / L)
  result.b = uint8(a.b.float + x * (b.b.float - a.b.float) / L)
  when T is ColorRGBA:
    result.a = uint8(a.a.float + x * (b.a.float - a.a.float) / L)
