import images, colors
import math

const
  kernelSmoothing = [[1.0, 1.0, 1.0],
                     [1.0, 2.0, 1.0],
                     [1.0, 1.0, 1.0]]
  kernelSharpening = [[-1.0, -1.0, -1.0],
                      [-1.0,  9.0, -1.0],
                      [-1.0, -1.0, -1.0]]
  kernelSharpen = [[ 0.0, -1.0,  0.0],
                   [-1.0,  5.0, -1.0],
                   [ 0.0, -1.0,  0.0]]
  kernelEdgeDetection = [[ 1.0, 0.0,-1.0],
                         [ 0.0, 0.0, 0.0],
                         [-1.0, 0.0, 1.0]]
  kernelEdgeDetection2 = [[0.0, 1.0, 0.0],
                          [1.0,-4.0, 1.0],
                          [0.0, 1.0, 0.0]]
  kernelEdgeDetection3 = [[-1.0, -1.0, -1.0],
                          [-1.0,  8.0, -1.0],
                          [-1.0, -1.0, -1.0]]
  kernelRaised = [[0.0, 0.0,-2.0],
                  [0.0, 2.0, 0.0],
                  [1.0, 0.0, 0.0]]
  kernelBoxBlur = [[1.0, 1.0, 1.0],
                   [1.0, 1.0, 1.0],
                   [1.0, 1.0, 1.0]]
  kernelMotionBlur = [[0.0, 0.0, 1.0],
                      [0.0, 0.0, 0.0],
                      [1.0, 0.0, 0.0]]
  kernelGaussianBlur5 = [[1.0,  4.0,  6.0,  4.0, 1.0],
                         [4.0, 16.0, 24.0, 16.0, 4.0],
                         [6.0, 24.0, 36.0, 24.0, 6.0],
                         [4.0, 16.0, 24.0, 16.0, 4.0],
                         [1.0,  4.0,  6.0,  4.0, 1.0]]
  kernelUnsharpMasking = [[1.0,  4.0,   6.0,  4.0, 1.0],
                          [4.0, 16.0,  24.0, 16.0, 4.0],
                          [6.0, 24.0,-476.0, 24.0, 6.0],
                          [4.0, 16.0,  24.0, 16.0, 4.0],
                          [1.0,  4.0,   6.0,  4.0, 1.0]]

func withKernel*(img: var Image, k: openArray[array | seq | openArray]): Image =
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
      var r, g, b = 0.0
      for j in 0..<kh:
        let ry = (y + j) * img.w
        for i in 0..<kw:
          let rx = x + i
          r += img[rx + ry][0].float * k[i][j]
          g += img[rx + ry][1].float * k[i][j]
          b += img[rx + ry][2].float * k[i][j]
      result[x + yw][0] = uint8 clamp(r / denom, 0, 255)
      result[x + yw][1] = uint8 clamp(g / denom, 0, 255)
      result[x + yw][2] = uint8 clamp(b / denom, 0, 255)

template genFilter(n): untyped =
  template `filtered n`*(i: Image): Image = i.withKernel `kernel n`
  template `filter n`*(i: var Image) = i = i.withKernel `kernel n`

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

func quantize*(c: var Color, factor: uint8) =
  c[0] = uint8(round(factor.float * c[0].float / 255.0) * float(255'u8 div factor))
  c[1] = uint8(round(factor.float * c[1].float / 255.0) * float(255'u8 div factor))
  c[2] = uint8(round(factor.float * c[2].float / 255.0) * float(255'u8 div factor))

func quantized*(c: Color, factor: uint8): Color =
  [uint8(round(factor.float * c[0].float / 255.0) * float(255'u8 div factor)),
   uint8(round(factor.float * c[1].float / 255.0) * float(255'u8 div factor)),
   uint8(round(factor.float * c[2].float / 255.0) * float(255'u8 div factor)),
   c[3]]

func filterGreyscale*(image: var Image) =
  for pixel in image.data.mitems:
    pixel.all = uint8 round(pixel.r.float * 0.2126 +
                            pixel.g.float * 0.7152 +
                            pixel.b.float * 0.0722)

func filterNegative*(image: var Image) =
    for pixel in image.data.mitems:
      pixel.r = 255'u8 - pixel.r
      pixel.g = 255'u8 - pixel.g
      pixel.b = 255'u8 - pixel.b

func filterSepia*(image: var Image) =
  for pixel in image.data.mitems:
    let prev = pixel
    pixel.r = uint8 min(prev.r.float * 0.393 + prev.g.float * 0.769 + prev.b.float * 0.189, 255)
    pixel.g = uint8 min(prev.r.float * 0.349 + prev.g.float * 0.686 + prev.b.float * 0.168, 255)
    pixel.b = uint8 min(prev.r.float * 0.272 + prev.g.float * 0.534 + prev.b.float * 0.131, 255)

template genFiltered(name): untyped =
  func `filtered name`*(image: Image): Image =
    result = image
    result.`filter name`

genFiltered Greyscale
genFiltered Negative
genFiltered Sepia
