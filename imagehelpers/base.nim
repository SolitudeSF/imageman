import sequtils, math, random
import nimPNG

type
 Color3* = array[3, uint8]
 Color4* = array[4, uint8]
 Color* = Color3 | Color4
 Image3* = seq[seq[Color3]]
 Image4* = seq[seq[Color4]]
 Image* = Image3 | Image4
 Point* = tuple[x, y: int]

const
  white*   = [255'u8, 255'u8, 255'u8]
  black*   = [0'u8  , 0'u8  , 0'u8  ]
  red*     = [255'u8, 0'u8  , 0'u8  ]
  green*   = [0'u8  , 255'u8, 0'u8  ]
  blue*    = [0'u8  , 0'u8  , 255'u8]
  yellow*  = [255'u8, 255'u8, 0'u8  ]
  magenta* = [255'u8, 0'u8  , 255'u8]

proc isInside*(p: Point, i: Image): bool = p.x >= 0 and p.y >= 0 and p.x < i.len and p.y < i[0].len

template `[]`*(i: Image, x, y: SomeOrdinal): Color = i[x][y]
template `[]`*(i: Image, p: Point): Color = i[p.x][p.y]
template `[]=`*(i: var Image, x, y: SomeOrdinal, c: Color) = i[x][y] = c
template `[]=`*(i: var Image, p: Point, c: Color) = i[p.x][p.y] = c

template `r`*(c: Color): uint8 = c[0]
template `g`*(c: Color): uint8 = c[1]
template `b`*(c: Color): uint8 = c[2]
template `a`*(c: Color4): uint8 = c[3]
template `r=`*(c: var Color, i: uint8) = c[0] = i
template `g=`*(c: var Color, i: uint8) = c[1] = i
template `b=`*(c: var Color, i: uint8) = c[2] = i
template `a=`*(c: var Color4, i: uint8) = c[3] = i

proc addAlpha*(c: Color3, a = 255'u8): Color4 = [c.r, c.g, c.b, a]
proc removeAlpha*(c: Color4): Color3 = [c.r, c.g, c.b]

proc `.*=`*(c: var Color, i: uint8) =
  c.r = i
  c.g = i
  c.b = i

proc blendColorValue(a, b: uint8, t: float): uint8 =
  uint8 sqrt((1.0 - t) * a.float * a.float + t * b.float * b.float)

proc `+`*(a, b: Color): Color = [blendColorValue(a.r, b.r, 0.3),
                                 blendColorValue(a.g, b.g, 0.3),
                                 blendColorValue(a.b, b.b, 0.3)]

proc `$`*(c: Color3): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ")"

proc `$`*(c: Color4): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

proc randomColor*: Color =
  randomize()
  [uint8 random(0..255), uint8 random(0..255), uint8 random(0..255)]

proc isGreyscale*(c: Color): bool =
  c.r == c.g and c.r == c.b

proc interpolate*(a, b: Color3, x, L: int): Color =
  result.r = uint8(a.r.float + x.float * (b.r.float - a.r.float) / L.float)
  result.g = uint8(a.g.float + x.float * (b.g.float - a.g.float) / L.float)
  result.b = uint8(a.b.float + x.float * (b.b.float - a.b.float) / L.float)

proc interpolate*(a, b: Color4, x, L: int): Color =
  result.r = uint8(a.r.float + x.float * (b.r.float - a.r.float) / L.float)
  result.g = uint8(a.g.float + x.float * (b.g.float - a.g.float) / L.float)
  result.b = uint8(a.b.float + x.float * (b.b.float - a.b.float) / L.float)
  result.a = uint8(a.a.float + x.float * (b.a.float - a.a.float) / L.float)

proc newImage*(h, w: SomeOrdinal, c: Color = white): Image = newSeqWith(h, newSeqWith(w, c))

proc strToImage3*(str: string, width, height: SomeOrdinal): Image3 =
 result = newSeqWith(height, newSeq[Color3](width))
 let s = cast[seq[uint8]](str)
 for y in 0..<height:
  for x in 0..<width:
   for i in 0..2: result[y][x][i] = s[((y * width) + x) * 3 + i]

proc strToImage4*(str: string, width, height: SomeOrdinal): Image4 =
 result = newSeqWith(height, newSeq[Color4](width))
 let s = cast[seq[uint8]](str)
 for y in 0..<height:
  for x in 0..<width:
   for i in 0..3: result[y][x][i] = s[((y * width) + x) * 4 + i]

proc imageToStr*(img: Image): string =
 var res = newSeq[uint8]()
 for row in img:
  for pixel in row:
   for value in pixel: res.add value
 result = cast[string](res)

proc loadImage3*(file: string): Image3 =
  let source = loadPNG24(file)
  result = source.data.strToImage3(source.width, source.height)

proc loadImage4*(file: string): Image4 =
  let source = loadPNG32(file)
  result = source.data.strToImage4(source.width, source.height)

template loadImage*(file: string): Image = file.loadImage3

proc saveImage*(image: Image3, file: string) =
  discard savePNG24(file, image.imageToStr, image[0].len, image.len)

proc saveImage*(image: Image4, file: string) =
  discard savePNG32(file, image.imageToStr, image[0].len, image.len)
