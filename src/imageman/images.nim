import algorithm
import ./colors, ./util

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

  Bucket = object
    c: ColorRGBF64
    n: float64

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
  i.data[x + y * i.w]

template `[]`*(i: Image, x: int): Color =
  ## Alias for accessing `i.data` values.
  i.data[x]

template `[]`*(i: Image, p: Point): Color =
  ## Access `i.data` using Point type.
  i.data[p.x + p.y * i.w]

template `[]=`*(i: var Image, x, y: int, c: Color) =
  ## Sugar for setting the pixel value using x, y coordinates like `i[x, y]`.
  i.data[x + y * i.w] = c

template `[]=`*(i: var Image, x: int, c: Color) =
  ## Alias for setting `i.data` values.
  i.data[x] = c

template `[]=`*(i: var Image, p: Point, c: Color) =
  ## Set `i.data` using Point type.
  i.data[p.x + p.y * i.w] = c

template colorType*[T: Color](i: Image[T]): typedesc[T] = T

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

func initImage*[T: Color](i: var Image[T], w, h: Natural) =
  i = initImage[T](w, h)

when defined(gcDestructors):
  func converted*[I, T: Color](i: sink Image[I], t: typedesc[T]): Image[T] =
    ## Converts image color mode if appropriate converter found.
    when T is I:
      result = i
    else:
      result.initImage(i.width, i.height)
      for n in 0..i.data.high:
        result[n] = i[n].to(T)
else:
  template converted*[I, T: Color](i: Image[I], t: typedesc[T]): Image[T] =
    ## Converts image color mode if appropriate converter found.
    when T is I:
      i
    else:
      var result = initImage[T](i.width, i.height)
      for n in 0..i.data.high:
        result[n] = i[n].to(t)
      result

func fill*[T: Color](i: var Image[T], c: T) =
  ## Fills entire image with single color.
  for n in 0..i.data.high:
    i[n] = c

func copyRegion*[T: Color](image: Image[T], x, y, w, h: int): Image[T] =
  ## Copies region at x, y coordinates with w, h dimensions into a new image.
  result.initImage(w, h)
  for i in 0..<h:
    copyMem addr result[i * w], unsafeAddr image[x, i + y], w * sizeof(T)

func copyRegion*[T: Color](image: Image[T], r: Rect): Image[T] =
  ## Copies region specified by a rectangle into a new image.
  copyRegion(image, r.x, r.y, r.w, r.h)

func `[]`*[T: Color](image: Image[T], x, y: Slice[int]): Image[T] =
  ## Slice syntax for region copy.
  image.copyRegion(min(x.a, x.b), min(y.a, y.b), abs(x.b - x.a) + 1, abs(y.b - y.a) + 1)

func blit*[T: Color](dest: var Image[T], src: Image[T], x, y: int) =
  ## Blit image `src` onto the `dest` in specified coordinates
  for i in 0..<src.height:
    copyMem addr dest[x, i + y], unsafeAddr src[0, i], src.width * sizeof(T)

func blit*[T: Color](dest: var Image[T], src: Image[T], x, y: int, rect: Rect) =
  ## Blit fragment of image `src` delimited by rectangle in specified coordinates.
  for i in 0..<rect.h:
    copyMem addr dest[x, i + y], unsafeAddr src[rect.x, i + rect.y], rect.w * sizeof(T)

func blitAlpha*[T: ColorA](dest: var Image[T], src: Image[T], x, y: int) =
  ## Dumb version of blend that copies pixels only if they are fully opaque
  for i in 0..<src.height:
    let
      destStrides = (i + y) * dest.width
      srcStrides = i * src.width
    for j in 0..<src.width:
      let
        destCoord = destStrides + j + x
        srcCoord = srcStrides + j
      if src[srcCoord].a == T.maxComponentValue:
        dest[destCoord] = src[srcCoord]

func blend*[T: ColorA](dest: var Image[T], src: Image[T], x, y: int) =
  for i in 0..<src.height:
    let
      destStrides = (i + y) * dest.width
      srcStrides = i * src.width
    for j in 0..<src.width:
      let
        destCoord = destStrides + j + x
        destPixel = dest[destCoord]
        srcCoord = srcStrides + j
        srcPixel = src[srcCoord]
      if srcPixel.a > 0:
        let
          inverseAlpha = T.maxComponentValue.precise - srcPixel.a.precise
          alpha = srcPixel.a.precise + destPixel.a.precise * inverseAlpha
        for idx in colorIndexes T:
          dest[destCoord][idx] = componentType(T) (
            (srcPixel[idx].precise * srcPixel.a.precise +
             destPixel[idx].precise * destPixel.a.precise * inverseAlpha) / alpha)

func paddedEmpty*[T: Color](img: Image[T], padX, padY: int): Image[T] =
  ## Returns padded image with default color. Transparent for images with alpha channel.
  result.initImage(img.w + padX * 2, img.h + padY * 2)
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

func padded*[T: Color](img: Image[T], padX, padY: int, kind: PadKind): Image[T] =
  ## Returns padded image with padding algorithm specified by `kind`.
  case kind
  of pkEmpty: img.paddedEmpty padX, padY
  of pkExtend: img.paddedExtend padX, padY
  of pkWrap: img.paddedWrap padX, padY
  of pkMirror: img.paddedMirror padX, padY

paddedEmpty.genMutating padEmpty, "Pads the image with empty pixels."
paddedExtend.genMutating padExtend, "Pads the image extending the edge pixels."
paddedWrap.genMutating padWrap, "Pads the image wrapping the image."
paddedMirror.genMutating padMirror, "Pads the image mirroring the image onto the padding."
padded.genMutating pad, "Pads the image with padding algorithm specified by `kind`."

func flippedHoriz*[T: Color](img: Image[T]): Image[T] =
  ## Returns image flipped horizontally
  result = img
  for y in 0..<img.h:
    let
      yw = y * img.w
      yw1 = yw + img.w - 1
    for i in 0..<img.w:
      result[yw + i] = img[yw1 - i]

func flippedVert*[T: Color](img: Image[T]): Image[T] =
  ## Returns image flipped vertically
  result = img
  for y in 0..<img.h div 2:
    let
      a = y * img.w..<(y + 1) * img.w
      b = (img.h - y - 1) * img.w..<(img.h - y) * img.w
    result.data[a] = img.data[b]
    result.data[b] = img.data[a]

func flipHoriz*[T: Color](img: var Image[T]) =
  ## Flips images horizontally
  for y in 0..<img.h:
    let
      yw = y * img.w
      yw1 = yw + img.w - 1
    for x in 0..<img.w div 2:
      swap img[yw + x], img[yw1 - x]

func flipVert*[T: Color](img: var Image[T]) =
  ## Flips images vertically
  for y in 0..<img.h div 2:
    let
      a = (y * img.w)..<(y + 1) * img.w
      b = (img.h - y - 1) * img.w..<(img.h - y) * img.w
    let t = img.data[a]
    img.data[a] = img.data[b]
    img.data[b] = t

func cmp(a, b: Bucket): int = cmp(a.n, b.n)

func getDominantColors*[T: Color](i: Image[T], threshold = 0.01): seq[ColorRGBF64] =
  ## Returns sequence of dominant colors
  var
    buckets: array[2, array[2, array[2, Bucket]]]
    sampledCount: float64

  for pixel in i.data:
    let
      index = pixel.to(ColorRGBU)
      pixel = pixel.to(ColorRGBAF64)
      i = index.r shr 7
      j = index.g shr 7
      k = index.b shr 7

    when T is ColorA:
      let alpha = pixel.a
    else:
      const alpha = 1.0

    buckets[i][j][k].c.r += pixel.r * alpha
    buckets[i][j][k].c.g += pixel.g * alpha
    buckets[i][j][k].c.b += pixel.b * alpha
    buckets[i][j][k].n += alpha
    sampledCount += alpha

  var averages: seq[Bucket]
  for i in 0..1:
    for j in 0..1:
      for k in 0..1:
        template currentBucket: untyped = buckets[i][j][k]
        if currentBucket.n > 0.0:
          averages.add Bucket(
            c: ColorRGBF64 [
              currentBucket.c.r / currentBucket.n,
              currentBucket.c.g / currentBucket.n,
              currentBucket.c.b / currentBucket.n
            ],
            n: currentBucket.n
          )

  sort averages, cmp

  for bucket in averages:
    if bucket.n / sampledCount > threshold:
      result.add bucket.c

import ./private/backends
export backends
