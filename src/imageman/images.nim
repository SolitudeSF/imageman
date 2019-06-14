import sequtils, math, random, streams, endians
import nimPNG
import colors

type
 Image* = object
   w*, h*: int
   data*: seq[Color]
 Point* = tuple[x, y: int]

func isInside*(p: Point, i: Image): bool = p.x >= 0 and p.y >= 0 and p.x < i.h and p.y < i.w

template `[]`*(i: Image, x, y: int): Color = i.data[x + y * i.w]
template `[]`*(i: Image, x: int): Color = i.data[x]
template `[]`*(i: Image, p: Point): Color = i.data[p.x + p.y * i.w]
template `[]=`*(i: var Image, x, y: int, c: Color) = i.data[x + y * i.w] = c
template `[]=`*(i: var Image, x: int, c: Color) = i.data[x] = c
template `[]=`*(i: var Image, p: Point, c: Color) = i.data[p.x + p.y * i.w] = c

func newImage*(w, h: Natural): Image =
  result.data = newSeq[Color](w * h)
  result.h = h.int
  result.w = w.int

func pngToImage(str: string, w, h: int): Image =
 result = newImage(w, h)
 var str = str
 copyMem addr result.data[0], addr str[0], str.len

func imageToPNG(img: Image): string =
 var data = img.data
 result = newString data.len * 4
 copyMem addr result[0], addr data[0], data.len * 4

proc loadPNG*(file: string): Image =
  let source = loadPNG32 file
  source.data.pngToImage(source.width, source.height)

proc savePNG*(image: Image, file: string) =
  discard savePNG32(file, image.imageToPNG, image.w, image.h)
