import ./images, ./colors, ./util
import math

func toKernel*(a: openArray[float32], width: int): Image[ColorGF] =
  result.initImage width, a.len div width
  copy result.data, a, a.len, ColorGF [it]

func convolved*[T: Color](img: Image[T], k: Image[ColorGF], padKind = pkMirror): Image[T] =
  result = initImage[T](img.width, img.height)

  let
    kh = k.height div 2
    kw = k.width div 2
    src = img.padded(kw, kh, padKind)
    denom = block:
      var s = 0.0
      for i in k.data:
        s += i[0]
      if s == 0:
        1.0
      else:
        s

  for y in 0..<result.height:
    let yw = y * result.width
    for x in 0..<result.width:
      var acc: array[T.colorComponentCount, float32]
      let precalc = (y + kh) * src.width + kw + x
      for j in 0..<k.height:
        let precalc = precalc + (j - kh) * src.width
        for i in 0..<k.width:
          let
            pos = precalc + i - kw
            coeff = k[j * k.width + i][0]
          T.forEachColorIndex i:
            acc[i] += src[pos][i].precise * coeff
      let target = yw + x
      when T.componentType is uint8:
        T.forEachColorIndex i:
          result[target][i] = componentType(T) clamp(acc[i] / denom, 0, T.maxComponentValue.precise)
      else:
        T.forEachColorIndex i:
          result[target][i] = componentType(T) acc[i] / denom
      when T is ColorA:
        result[target].a = img[target].a

func quantize*[T: ColorRGBFAny | ColorRGBF64Any](c: var T, factor: float) =
  T.forEachColorIndex i:
    c[i] = round(factor * c[i]) / factor

func quantize*[T: ColorRGBUAny](c: var T, factor: uint8) =
  let
    a = factor.float32 / 255.0
    b = float32(255'u8 div factor)
  T.forEachColorIndex i:
    c[i] = uint8(round(a * c[i].float32) * b)

func quantized*[T: ColorRGBAny](c: T, factor: T.componentType): T =
  result = c
  quantize result, factor

func filterGreyscale*[T: ColorRGBAny](image: var Image[T]) =
  for pixel in image.data.mitems:
    let c = (T.componentType) (pixel.r.precise * 0.2126 +
      pixel.g.precise * 0.7152 + pixel.b.precise * 0.0722)
    T.forEachColorIndex i:
      pixel[i] = c

func filterNegative*[T: ColorRGBAny](image: var Image[T]) =
  for pixel in image.data.mitems:
    T.forEachColorIndex i:
      pixel[i] = T.maxComponentValue - pixel[i]

func filterSepia*[T: ColorRGBAny](image: var Image[T]) =
  for pixel in image.data.mitems:
    let prev = pixel
    pixel.r = componentType(T) min(prev.r.precise * 0.393 + prev.g.precise * 0.769 + prev.b.precise * 0.189, T.maxComponentValue.precise)
    pixel.g = componentType(T) min(prev.r.precise * 0.349 + prev.g.precise * 0.686 + prev.b.precise * 0.168, T.maxComponentValue.precise)
    pixel.b = componentType(T) min(prev.r.precise * 0.272 + prev.g.precise * 0.534 + prev.b.precise * 0.131, T.maxComponentValue.precise)

filterGreyscale.genNonMutating filteredGreyscale
filterNegative.genNonMutating filteredNegative
filterSepia.genNonMutating filteredSepia
