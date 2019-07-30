import images, colors
import math

const
  kernelSmoothing* = [[1.0, 1.0, 1.0],
                      [1.0, 2.0, 1.0],
                      [1.0, 1.0, 1.0]]
  kernelSharpening* = [[-1.0, -1.0, -1.0],
                       [-1.0,  9.0, -1.0],
                       [-1.0, -1.0, -1.0]]
  kernelSharpen* = [[ 0.0, -1.0,  0.0],
                    [-1.0,  5.0, -1.0],
                    [ 0.0, -1.0,  0.0]]
  kernelEdgeDetection* = [[ 1.0, 0.0,-1.0],
                          [ 0.0, 0.0, 0.0],
                          [-1.0, 0.0, 1.0]]
  kernelEdgeDetection2* = [[0.0, 1.0, 0.0],
                           [1.0,-4.0, 1.0],
                           [0.0, 1.0, 0.0]]
  kernelEdgeDetection3* = [[-1.0, -1.0, -1.0],
                           [-1.0,  8.0, -1.0],
                           [-1.0, -1.0, -1.0]]
  kernelRaised* = [[0.0, 0.0,-2.0],
                   [0.0, 2.0, 0.0],
                   [1.0, 0.0, 0.0]]
  kernelBoxBlur* = [[1.0, 1.0, 1.0],
                    [1.0, 1.0, 1.0],
                    [1.0, 1.0, 1.0]]
  kernelMotionBlur* = [[0.0, 0.0, 1.0],
                       [0.0, 0.0, 0.0],
                       [1.0, 0.0, 0.0]]
  kernelGaussianBlur5* = [[1.0,  4.0,  6.0,  4.0, 1.0],
                          [4.0, 16.0, 24.0, 16.0, 4.0],
                          [6.0, 24.0, 36.0, 24.0, 6.0],
                          [4.0, 16.0, 24.0, 16.0, 4.0],
                          [1.0,  4.0,  6.0,  4.0, 1.0]]
  kernelUnsharpMasking* = [[1.0,  4.0,   6.0,  4.0, 1.0],
                           [4.0, 16.0,  24.0, 16.0, 4.0],
                           [6.0, 24.0,-476.0, 24.0, 6.0],
                           [4.0, 16.0,  24.0, 16.0, 4.0],
                           [1.0,  4.0,   6.0,  4.0, 1.0]]

func withKernel*[T: Color](img: var Image[T], k: openArray[array | seq | openArray]): Image[T] =
  result = img
  let
    kh = k.len
    kw = k[0].len
  var denom = 0.0

  for i in k:
    for j in i:
      denom += j
  if denom == 0:
    denom = 1

  for y in 0..img.h - kw:
    let yw = y * img.w
    for x in 0..img.w - kh:
      var r, g, b = 0.0'f32
      for j in 0..<kh:
        let ry = (y + j) * img.w
        for i in 0..<kw:
          let rx = x + i
          r += img[rx + ry][0].precise * k[i][j]
          g += img[rx + ry][1].precise * k[i][j]
          b += img[rx + ry][2].precise * k[i][j]
      result[x + yw][0] = (T.componentType) clamp(r / denom, 0, T.maxComponentValue.precise)
      result[x + yw][1] = (T.componentType) clamp(g / denom, 0, T.maxComponentValue.precise)
      result[x + yw][2] = (T.componentType) clamp(b / denom, 0, T.maxComponentValue.precise)

template genFilter(n): untyped =
  template `filtered n`*(i: Image): untyped = withKernel i, `kernel n`
  template `filter n`*(i: var Image): untyped = i = i.withKernel `kernel n`

genFilter Smoothing
genFilter Sharpening
genFilter Sharpen
genFilter Raised
genFilter EdgeDetection
genFilter EdgeDetection2
genFilter EdgeDetection3
genFilter BoxBlur
genFilter MotionBlur
genFilter GaussianBlur5
genFilter UnsharpMasking

func quantize*(c: var ColorRGBFAny, factor: float32) =
  c[0] = round(factor * c[0]) / factor
  c[1] = round(factor * c[1]) / factor
  c[2] = round(factor * c[2]) / factor

func quantized*(c: ColorRGBFAny, factor: float32): ColorRGBAF =
  result = c
  quantize result, factor

func quantize*[T: ColorRGBUAny](c: var T, factor: uint8) =
  c[0] = uint8(round(factor.float32 * c[0].float32 / 255.0) * float32(255'u8 div factor))
  c[1] = uint8(round(factor.float32 * c[1].float32 / 255.0) * float32(255'u8 div factor))
  c[2] = uint8(round(factor.float32 * c[2].float32 / 255.0) * float32(255'u8 div factor))

func quantized*[T: ColorRGBUAny](c: T, factor: uint8): T =
  result = c
  quantize result, factor

func filterGreyscale*[T: Color](image: var Image[T]) =
  for pixel in image.data.mitems:
    let c = (T.componentType) (pixel.r.precise * 0.2126 +
      pixel.g.precise * 0.7152 + pixel.b.precise * 0.0722)
    pixel.r = c
    pixel.g = c
    pixel.b = c

func filterNegative*[T: Color](image: var Image[T]) =
    for pixel in image.data.mitems:
      pixel.r = T.maxComponentValue - pixel.r
      pixel.g = T.maxComponentValue - pixel.g
      pixel.b = T.maxComponentValue - pixel.b

func filterSepia*[T: Color](image: var Image[T]) =
  for pixel in image.data.mitems:
    let prev = pixel
    pixel.r = (T.componentType) min(prev.r.precise * 0.393 + prev.g.precise * 0.769 + prev.b.precise * 0.189, T.maxComponentValue.precise)
    pixel.g = (T.componentType) min(prev.r.precise * 0.349 + prev.g.precise * 0.686 + prev.b.precise * 0.168, T.maxComponentValue.precise)
    pixel.b = (T.componentType) min(prev.r.precise * 0.272 + prev.g.precise * 0.534 + prev.b.precise * 0.131, T.maxComponentValue.precise)

template genFiltered(name): untyped =
  func `filtered name`*[T: Color](image: Image[T]): Image[T] =
    result = image
    result.`filter name`

genFiltered Greyscale
genFiltered Negative
genFiltered Sepia
