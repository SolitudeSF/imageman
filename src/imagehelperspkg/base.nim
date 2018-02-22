import sequtils, math, random
import nimPNG

type
 Color* = array[4, uint8]
 Image* = object
   w*, h*: int
   data*: seq[Color]
 Point* = tuple[x, y: int]

proc isInside*(p: Point, i: Image): bool = p.x >= 0 and p.y >= 0 and p.x < i.h and p.y < i.w

template `[]`*(i: Image, x, y: int): Color = i.data[x + y * i.w]
template `[]`*(i: Image, x: int): Color = i.data[x]
template `[]`*(i: Image, p: Point): Color = i.data[p.x + p.y * i.w]
template `[]=`*(i: var Image, x, y: int, c: Color) = i.data[x + y * i.w] = c
template `[]=`*(i: var Image, x: int, c: Color) = i.data[x] = c
template `[]=`*(i: var Image, p: Point, c: Color) = i.data[p.x + p.y * i.w] = c

template `r`*(c: Color): uint8 = c[0]
template `g`*(c: Color): uint8 = c[1]
template `b`*(c: Color): uint8 = c[2]
template `a`*(c: Color): uint8 = c[3]
template `r=`*(c: var Color, i: uint8) = c[0] = i
template `g=`*(c: var Color, i: uint8) = c[1] = i
template `b=`*(c: var Color, i: uint8) = c[2] = i
template `a=`*(c: var Color, i: uint8) = c[3] = i

const
  white*       = [255'u8, 255'u8, 255'u8, 255'u8]
  black*       = [0'u8  , 0'u8  , 0'u8  , 255'u8]
  red*         = [255'u8, 0'u8  , 0'u8  , 255'u8]
  green*       = [0'u8  , 255'u8, 0'u8  , 255'u8]
  blue*        = [0'u8  , 0'u8  , 255'u8, 255'u8]
  yellow*      = [255'u8, 255'u8, 0'u8  , 255'u8]
  magenta*     = [255'u8, 0'u8  , 255'u8, 255'u8]
  transparent* = [255'u8, 255'u8, 255'u8, 0'u8  ]

proc `.*=`*(c: var Color, i: uint8) =
  c.r = i
  c.g = i
  c.b = i

proc blendColorValue(a, b: uint8, t: float): uint8 =
  uint8 sqrt((1.0 - t) * a.float * a.float + t * b.float * b.float)

proc `+`*(a, b: Color): Color = [blendColorValue(a.r, b.r, 0.3),
                                 blendColorValue(a.g, b.g, 0.3),
                                 blendColorValue(a.b, b.b, 0.3),
                                 a.a]

proc `$`*(c: Color): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

proc randomColor*: Color = [uint8 random(0..255),
                            uint8 random(0..255),
                            uint8 random(0..255),
                            255'u8]

proc isGreyscale*(c: Color): bool =
  c.r == c.g and c.r == c.b

proc interpolate*(a, b: Color, x: float, L = 1.0): Color =
  result.r = uint8(a.r.float + x * (b.r.float - a.r.float) / L)
  result.g = uint8(a.g.float + x * (b.g.float - a.g.float) / L)
  result.b = uint8(a.b.float + x * (b.b.float - a.b.float) / L)
  result.a = uint8(a.a.float + x * (b.a.float - a.a.float) / L)

proc newImage*(w, h: int, c: Color = white): Image =
  result.data = newSeq[Color](w * h)
  result.h = h
  result.w = w

proc strToImage*(str: string, w, h: int): Image =
 result = newImage(w, h)
 let s = cast[seq[uint8]](str)
 for idx in 0..<h * w:
   for i in 0..3: result.data[idx][i] = s[idx * 4 + i]

proc imageToStr*(img: Image): string =
 var res = newSeq[uint8]()
 for pixel in img.data:
   for value in pixel: res.add value
 result = cast[string](res)

proc loadImage*(file: string): Image =
  let source = loadPNG32 file
  source.data.strToImage(source.width, source.height)

proc saveImage*(image: Image, file: string) =
  discard savePNG32(file, image.imageToStr, image.w, image.h)
