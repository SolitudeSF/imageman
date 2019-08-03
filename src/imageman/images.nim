import stb_image/[read, write]
import colors
export ColorRGBU, ColorRGBAU, ColorRGBF, ColorRGBAF, colors.`[]`, colors.`[]=`, colors.len, colors.high, colors.`==`

type
  Image*[T: Color] = object
    ## Image object. `data` field is a sequence of pixels stored in arrays.
    width*, height*: int
    data*: seq[T]
  Point* = tuple[x, y: int]
    ## Pair of coordinates.
  Rect* = object
    ## Rectangle object. x and y coordinates represent top-left corner.
    x*, y*, w*, h*: int
  PadKind* = enum
    ## Enum representing all padding algorithms.
    pkEmpty, pkExtend, pkWrap, pkMirror

func contains*(i: Image, p: Point): bool =
  ## Checks if point is inside the image.
  p.x >= 0 and p.y >= 0 and p.x < i.height and p.y < i.width

func contains*(i: Image, x, y: int): bool =
  ## Checks if point with x, y coordinates is inside the image.
  x >= 0 and y >= 0 and x < i.height and y < i.width

template `in`*(p: Point, i: Image): bool =
  ## Alias for contains.
  i.contains p

template w*(i: Image): int =
  ## Alias to `image.width`.
  i.width
template h*(i: Image): int =
  ## Alias to `image.height`.
  i.height

template `[]`*(i: Image, x, y: int): Color =
  ## Sugar for accessing the pixel value using x, y coordinates like `i[x, y]`.
  when defined(imagemanSafe):
    if i.contains(x, y): i.data[x + y * i.w]
  else:
    i.data[x + y * i.w]

template `[]`*(i: Image, x: int): Color =
  ## Alias for accessing `i.data` values.
  when defined(imagemanSafe):
    if x < i.data.len: i.data[x]
  else:
    i.data[x]

template `[]`*(i: Image, p: Point): Color =
  ## Access `i.data` using Point type.
  when defined(imagemanSafe):
    if p in i: i.data[p.x + p.y * i.w]
  else:
    i.data[p.x + p.y * i.w]

template `[]=`*(i: var Image, x, y: int, c: Color) =
  ## Sugar for setting the pixel value using x, y coordinates like `i[x, y]`.
  when defined(imagemanSafe):
    if i.contains(x, y): i.data[x + y * i.w] = c
  else:
    i.data[x + y * i.w] = c

template `[]=`*(i: var Image, x: int, c: Color) =
  ## Alias for setting `i.data` values.
  when defined(imagemanSafe):
    if x < i.data.len: i.data[x] = c
  else:
    i.data[x] = c

template `[]=`*(i: var Image, p: Point, c: Color) =
  ## Set `i.data` using Point type.
  when defined(imagemanSafe):
    if p in i: i.data[p.x + p.y * i.w] = c
  else:
    i.data[p.x + p.y * i.w] = c

func initRect*(x, y, w, h: int): Rect =
  ## Creates new `Rect` object.
  Rect(x: x, y: y, w: w, h: h)

func toRect*(a, b: Point): Rect =
  ## Converts pair of points to a rectangle.
  if a.x < b.x:
    result.x = a.x
    result.w = b.x - a.x
  else:
    result.x = b.x
    result.w = a.x - b.x
  if a.y < b.y:
    result.y = a.y
    result.h = b.y - a.y
  else:
    result.y = b.y
    result.h = a.y - b.y

func initImage*[T: Color](w, h: Natural): Image[T] =
  ## Creates new image with specified color mode and dimensions.
  Image[T](data: newSeq[T](w * h), height: h, width: w)

func copyRegion*[T: Color](image: Image[T], x, y, w, h: int): Image[T] =
  ## Copies region at x, y coordinates with w, h dimensions into a new image.
  result = initImage[T](w, h)
  for i in 0..<h:
    copyMem addr result[i * w], unsafeAddr image[x, i + y], w * sizeof(T)

func copyRegion*[T: Color](image: Image[T], r: Rect): Image[T] =
  ## Copies region specified by a rectangle into a new image.
  copyRegion(image, r.x, r.y, r.w, r.h)

func blit*[T: Color](dest: var Image[T], src: Image, x, y: int) =
  ## Blit image `src` onto the `dest` in specified coordinates
  for i in 0..<src.height:
    copyMem addr dest[x, i + y], unsafeAddr src[0, i], src.width * sizeof(T)

func blit*[T: Color](dest: var Image[T], src: Image, x, y: int, rect: Rect) =
  ## Blit fragment of image `src` delimited by rectangle in specified coordinates.
  for i in 0..<rect.h:
    copyMem addr dest[x, i + y], unsafeAddr src[rect.x, i + rect.y], rect.w * sizeof(T)

func paddedEmpty*[T: Color](img: Image[T], padX, padY: int): Image[T] =
  ## Returns padded image with default color. Transparent for images with alpha channel.
  result = initImage[T](img.w + padX * 2, img.h + padY * 2)
  result.blit img, padX, padY

func paddedExtend*[T: Color](img: Image[T], padX, padY: int): Image[T] =
  ## Returns padded image with edge pixels extended to fill the padding.
  result = img.paddedEmpty(padX, padY)
  let
    padW = result.width
    padH = result.height
    topY = padY * padW
    botY = (padH - padY - 1) * padW
    rightX = padW - padX - 1

  for y in 0..<padY:
    let yw = y * padW
    for x in 0..<padX:
      result[yw + x] = result[topY + padX]
    for x in padX..<padW - padX:
      result[yw + x] = result[topY + x]
    for x in padW - padX..<padW:
      result[yw + x] = result[topY + rightX]

  for y in padY..<padH - padY:
    let yw = y * padW
    for x in 0..<padX:
      result[yw + x] = result[yw + padX]
    for x in padW - padX..<padW:
      result[yw + x] = result[yw + rightX]

  for y in padH - padY..<padH:
    let yw = y * padW
    for x in 0..<padX:
      result[yw + x] = result[botY + padX]
    for x in padX..<padW - padX:
      result[yw + x] = result[botY + x]
    for x in padW - padX..<padW:
      result[yw + x] = result[botY + rightX]

func paddedWrap*[T: Color](img: Image[T], padX, padY: int): Image[T] =
  ## Returns padded image with image wrapped to fill the padding.
  result = img.paddedEmpty(padX, padY)
  let
    padW = result.w
    padH = result.h
    leftX = padW - padX * 2
    topY = (padH - padY * 2) * padW

  for y in padY..<padH - padY:
    let yw = y * padW
    for x in 0..<padX:
      result[yw + x] = result[yw + x + leftX]
    for x in padW - padX..<padW:
      result[yw + x] = result[yw + x - leftX]

  for y in 0..<padY:
    let yw = y * padW
    for x in 0..<padW:
      result[yw + x] = result[yw + x + topY]

  for y in padH - padY..<padH:
    let yw = y * padW
    for x in 0..<padW:
      result[yw + x] = result[yw + x - topY]

func paddedMirror*[T: Color](img: Image[T], padX, padY: int): Image[T] =
  ## Returns padded image with image mirrored to fill the padding.
  result = img.paddedEmpty(padX, padY)
  let
    padW = result.w
    padH = result.h
    leftX = padX * 2
    rightX = (padW - padX) * 2 - 1
    topY = padY * 2 * padW
    botY = ((padH - padY) * 2 - 1) * padW

  for y in padY..<padH - padY:
    let yw = y * padW
    for x in 0..<padX:
      result[yw + x] = result[yw - x + leftX]
    for x in padW - padX..<padW:
      result[yw + x] = result[yw - x + rightX]

  for y in 0..<padY:
    let yw = y * padW
    for x in 0..<padW:
      result[yw + x] = result[topY - yw + x]

  for y in padH - padY..<padH:
    let yw = y * padW
    for x in 0..<padW:
      result[yw + x] = result[botY - yw + x]

func padEmpty*[T: Color](img: var Image[T], padX, padY: int) =
  ## Pads the image with empty pixels.
  img = img.paddedEmpty(padX, padY)

func padExtend*[T: Color](img: var Image[T], padX, padY: int) =
  ## Pads the image extending the edge pixels.
  img = img.paddedExtend(padX, padY)

func padWrap*[T: Color](img: var Image[T], padX, padY: int) =
  ## Pads the image wrapping the image.
  img = img.paddedWrap(padX, padY)

func padMirror*[T: Color](img: var Image[T], padX, padY: int) =
  ## Pads the image mirroring the image onto the padding.
  img = img.paddedMirror(padX, padY)

func padded*[T: Color](img: Image[T], padX, padY: int, kind: PadKind): Image[T] =
  ## Returns padded image with padding algorithm specified by `kind`.
  case kind
  of pkEmpty: img.paddedEmpty padX, padY
  of pkExtend: img.paddedExtend padX, padY
  of pkWrap: img.paddedWrap padX, padY
  of pkMirror: img.paddedMirror padX, padY

func pad*[T: Color](img: var Image[T], padX, padY: int, kind: PadKind) =
  ## Pads the image with padding algorithm specified by `kind`.
  img = img.pad(padX, padY, kind)

template toColorMode(t: typedesc[Color]): untyped =
  when t is ColorA: RGBA else: RGB

template importData[T: Color](r: var seq[T], s: seq[byte]) =
  when T is ColorRGBFAny:
    for i in 0..r.high:
      r[i][0] = s[i * T.len].toLinear
      r[i][1] = s[i * T.len + 1].toLinear
      r[i][2] = s[i * T.len + 2].toLinear
      when T is ColorRGBAF:
        r[i][3] = s[i * 4 + 3].toLinear
  else:
    copyMem addr r[0], unsafeAddr s[0], s.len

template toExportData[T: Color](s: seq[T]): seq[byte] =
  when T is ColorRGBFAny:
    var r = newSeq[byte](s.len * 4)
    for i in 0..s.high:
      r[i * T.len]     = s[i][0].toUint8
      r[i * T.len + 1] = s[i][1].toUint8
      r[i * T.len + 2] = s[i][2].toUint8
      when T is ColorRGBAF:
        r[i * 4 + 3] = s[i][3].toUint8
    r
  else:
    cast[seq[byte]](s)

proc loadImage*[T: Color](file: string): Image[T] =
  ## Loads image with specified color mode from a filename.
  var
    w, h, channels: int
    data = load(file, w, h, channels, T.toColorMode)
  result = initImage[T](w, h)
  result.data.importData data

proc loadImageFromMemory*[T: Color](buffer: seq[byte]): Image[T] =
  ## Loads image with specified color mode from a sequence of bytes.
  var
    w, h, channels: int
    data = loadFromMemory(buffer, w, h, channels, T.toColorMode)
  result = initImage[T](w, h)
  result.data.importData data

proc savePNG*[T: Color](image: Image[T], file: string) =
  ## Saves the image in `png` format to a file.
  if not write.writePNG(file, image.w, image.h, T.toColorMode, image.data.toExportData):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveJPG*[T: Color](image: Image[T], file: string, quality: range[1..100] = 95) =
  ## Saves the image in `jpg` format to a file.
  ## Optional quality parameter can be specified in range 1..100.
  if not write.writeJPG(file, image.w, image.h, T.toColorMode, image.data.toExportData, quality):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveBMP*[T: Color](image: Image[T], file: string) =
  ## Saves the image in `bmp` format to a file.
  if not write.writeBMP(file, image.w, image.h, T.toColorMode, image.data.toExportData):
    raise newException(IOError, "Failed to write the image to " & file)

proc saveTGA*[T: Color](image: Image[T], file: string, useRLE = true) =
  ## Saves the image in `tga` format to a file.
  ## `useRLE` parameter can be specified to enable/disable RLE compressed data.
  if not write.writeTGA(file, image.w, image.h, T.toColorMode, image.data.toExportData, useRLE):
    raise newException(IOError, "Failed to write the image to " & file)

proc writePNG*[T: Color](image: Image[T]): seq[byte] =
  ## Converts image to a png data.
  write.writePNG(image.w, image.h, T.toColorMode, image.data.toExportData)

proc writeJPG*[T: Color](image: Image[T], quality: range[1..100] = 95): seq[byte] =
  ## Converts image to a jpg data.
  write.writeJPG(image.w, image.h, T.toColorMode, image.data.toExportData, quality)

proc writeBMP*[T: Color](image: Image[T]): seq[byte] =
  ## Converts image to a bmp data.
  write.writeBMP(image.w, image.h, T.toColorMode, image.data.toExportData)

proc writeTGA*[T: Color](image: Image[T], useRLE = true): seq[byte] =
  ## Converts image to a tga data.
  write.writeTGA(image.w, image.h, T.toColorMode, image.data.toExportData, useRLE)
