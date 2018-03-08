import sequtils, math, random, streams, endians
import nimPNG
import colors

type
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

proc newImage*(w, h: SomeInteger, c: Color = white): Image =
  result.data = newSeq[Color](w * h)
  result.h = h.int
  result.w = w.int

proc PNGToImage*(str: string, w, h: int): Image =
 result = newImage(w, h)
 let s = cast[seq[uint8]](str)
 for idx in 0..<h * w:
   for i in 0..3: result.data[idx][i] = s[idx * 4 + i]

proc imageToPNG*(img: Image): string =
 var res = newSeq[uint8]()
 for pixel in img.data:
   for value in pixel: res.add value
 result = cast[string](res)

proc loadPNG*(file: string): Image =
  let source = loadPNG32 file
  source.data.PNGToImage(source.width, source.height)

proc savePNG*(image: Image, file: string) =
  discard savePNG32(file, image.imageToPNG, image.w, image.h)

proc loadFF*(file: string): Image =
  var file = file.newFileStream
  file.setPosition 2000
  var
    width  = 0'u32
    height = 0'u32
  discard file.readData(addr width, 4)
  discard file.readData(addr height, 4)
  echo width, " ", height
  quit 0
  #result = newImage(width, height)
  #for i in 0..<width.int*height.int:
    #result[i][0] = file.readInt16.uint8
    #result[i][1] = file.readInt16.uint8
    #result[i][2] = file.readInt16.uint8
    #result[i][3] = file.readInt16.uint8

proc saveFF*(image: Image, file: string) =
  var file = file.newFileStream fmWrite
  file.write "farbfeld"
  file.write image.w.uint32
  file.write image.h.uint32
  for p in 0..image.data.high:
    for c in 0..3:
      file.write image[p][c].uint16
