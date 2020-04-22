import ./colors, ./util, ./private/[backends, imagetype]
export backends, imagetype
export ColorRGBU, ColorRGBAU, ColorRGBF, ColorRGBAF, colors.`[]`, colors.`[]=`, colors.len, colors.high, colors.`==`

type
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


func converted*[I, T: Color](i: Image[I], t: typedesc[T]): Image[T] =
  ## Converts image color mode if appropriate converter found.
  when T is I:
    result = i
  else:
    result = initImage[T](i.width, i.height)
    for n in 0..i.data.high:
      result[n] = i[n].to(T)

func fill*[T: Color](i: var Image[T], c: T) =
  ## Fills entire image with single color.
  for n in 0..i.data.high:
    i[n] = c

func copyRegion*[T: Color](image: Image[T], x, y, w, h: int): Image[T] =
  ## Copies region at x, y coordinates with w, h dimensions into a new image.
  result = initImage[T](w, h)
  for i in 0..<h:
    copyMem addr result[i * w], unsafeAddr image[x, i + y], w * sizeof(T)

func copyRegion*[T: Color](image: Image[T], r: Rect): Image[T] =
  ## Copies region specified by a rectangle into a new image.
  copyRegion(image, r.x, r.y, r.w, r.h)

func `[]`*[T: Color](image: Image[T], x, y: Slice[int]): Image[T] =
  ## Slice syntax for region copy.
  image.copyRegion(min(x.a, x.b), min(y.a, y.b), abs(x.b - x.a) + 1, abs(y.b - y.a) + 1)

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
