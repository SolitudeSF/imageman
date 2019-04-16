import math, random

type
  Color* = array[4, uint8]
  ColorF = array[4, float]
  ColorCMYK = array[5, float]
  ColorHSL = array[4, float]

const
  white*       = [255'u8, 255'u8, 255'u8, 255'u8]
  black*       = [0'u8  , 0'u8  , 0'u8  , 255'u8]
  red*         = [255'u8, 0'u8  , 0'u8  , 255'u8]
  green*       = [0'u8  , 255'u8, 0'u8  , 255'u8]
  blue*        = [0'u8  , 0'u8  , 255'u8, 255'u8]
  yellow*      = [255'u8, 255'u8, 0'u8  , 255'u8]
  magenta*     = [255'u8, 0'u8  , 255'u8, 255'u8]
  transparent* = [255'u8, 255'u8, 255'u8, 0'u8  ]

func min*(a, b, c: float): float = min(a, min(b, c))
func max*(a, b, c: float): float = max(a, max(b, c))

template r*(c: Color): uint8 = c[0]
template g*(c: Color): uint8 = c[1]
template b*(c: Color): uint8 = c[2]
template a*(c: Color): uint8 = c[3]
template `r=`*(c: var Color, i: uint8) = c[0] = i
template `g=`*(c: var Color, i: uint8) = c[1] = i
template `b=`*(c: var Color, i: uint8) = c[2] = i
template `a=`*(c: var Color, i: uint8) = c[3] = i

func `all=`*(c: var Color, i: uint8) =
  c.r = i
  c.g = i
  c.b = i

func blendColorValue*(a, b: uint8, t: float): uint8 =
  uint8 sqrt((1.0 - t) * a.float * a.float + t * b.float * b.float)

func `+`*(a, b: Color): Color = [blendColorValue(a.r, b.r, 0.3),
                                 blendColorValue(a.g, b.g, 0.3),
                                 blendColorValue(a.b, b.b, 0.3),
                                 a.a]

func `$`*(c: Color): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

proc randomColor*: Color = [uint8 rand(255),
                            uint8 rand(255),
                            uint8 rand(255),
                            255'u8]

func isGreyscale*(c: Color): bool =
  c.r == c.g and c.r == c.b

func interpolate*(a, b: Color, x: float, L = 1.0): Color =
  result.r = uint8(a.r.float + x * (b.r.float - a.r.float) / L)
  result.g = uint8(a.g.float + x * (b.g.float - a.g.float) / L)
  result.b = uint8(a.b.float + x * (b.b.float - a.b.float) / L)
  result.a = uint8(a.a.float + x * (b.a.float - a.a.float) / L)
