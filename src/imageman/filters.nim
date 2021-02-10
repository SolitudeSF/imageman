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
      if s == 0: 1.0 else: s

  for y in 0..<result.height:
    let yw = y * result.width
    for x in 0..<result.width:
      var r, g, b = 0.0'f32
      let precalc = (y + kh) * src.width + kw + x
      for j in 0..<k.height:
        let precalc = precalc + (j - kh) * src.width
        for i in 0..<k.width:
          let
            pos = precalc + i - kw
            kpos = j * k.width + i
          r += src[pos].r.precise * k[kpos][0]
          g += src[pos].g.precise * k[kpos][0]
          b += src[pos].b.precise * k[kpos][0]
      let target = yw + x
      result[target].r = (T.componentType) clamp(r / denom, 0, T.maxComponentValue.precise)
      result[target].g = (T.componentType) clamp(g / denom, 0, T.maxComponentValue.precise)
      result[target].b = (T.componentType) clamp(b / denom, 0, T.maxComponentValue.precise)
      when T is ColorA:
        result[target].a = img[target].a

func quantize*[T: ColorRGBFAny | ColorRGBF64Any](c: var T, factor: float) =
  c.r = round(factor * c.r) / factor
  c.g = round(factor * c.g) / factor
  c.b = round(factor * c.b) / factor

func quantize*[T: ColorRGBUAny](c: var T, factor: uint8) =
  c.r = uint8(round(factor.float32 * c.r.float32 / 255.0) * float32(255'u8 div factor))
  c.g = uint8(round(factor.float32 * c.g.float32 / 255.0) * float32(255'u8 div factor))
  c.b = uint8(round(factor.float32 * c.b.float32 / 255.0) * float32(255'u8 div factor))

func quantized*[T: ColorRGBAny](c: T, factor: T.componentType): T =
  result = c
  quantize result, factor

func filterGreyscale*[T: ColorRGBAny](image: var Image[T]) =
  for pixel in image.data.mitems:
    let c = (T.componentType) (pixel.r.precise * 0.2126 +
      pixel.g.precise * 0.7152 + pixel.b.precise * 0.0722)
    pixel.r = c
    pixel.g = c
    pixel.b = c

func filterNegative*[T: ColorRGBAny](image: var Image[T]) =
  for pixel in image.data.mitems:
    pixel.r = T.maxComponentValue - pixel.r
    pixel.g = T.maxComponentValue - pixel.g
    pixel.b = T.maxComponentValue - pixel.b

func filterSepia*[T: ColorRGBAny](image: var Image[T]) =
  for pixel in image.data.mitems:
    let prev = pixel
    pixel.r = componentType(T) min(prev.r.precise * 0.393 + prev.g.precise * 0.769 + prev.b.precise * 0.189, T.maxComponentValue.precise)
    pixel.g = componentType(T) min(prev.r.precise * 0.349 + prev.g.precise * 0.686 + prev.b.precise * 0.168, T.maxComponentValue.precise)
    pixel.b = componentType(T) min(prev.r.precise * 0.272 + prev.g.precise * 0.534 + prev.b.precise * 0.131, T.maxComponentValue.precise)

filterGreyscale.genNonMutating filteredGreyscale
filterNegative.genNonMutating filteredNegative
filterSepia.genNonMutating filteredSepia
