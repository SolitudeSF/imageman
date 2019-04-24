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

func applyKernel*(img: var Image, k: openArray[array | seq | openArray]) =
  let
    kh = k.len
    kw = k[0].len
  var
    denom = 0.0
    temp = img

  for i in k:
    for j in i:
      denom += j
  if denom == 0:
    denom = 1

  for x in 0..img.w - kh:
    for y in 0..img.h - kw:
      var r, g, b = 0.0
      for j in 0..kh-1:
        for i in 0..kw-1:
          let
            rx = x + i
            ry = y + j
          r += img[rx, ry][0].float * k[i][j]
          g += img[rx, ry][1].float * k[i][j]
          b += img[rx, ry][2].float * k[i][j]
      temp[x,y][0] = uint8 clamp(r / denom, 0, 255)
      temp[x,y][1] = uint8 clamp(g / denom, 0, 255)
      temp[x,y][2] = uint8 clamp(b / denom, 0, 255)
  img = temp

template genFilter(n): untyped =
  template `filter n`*(i: var Image) = i.applyKernel `kernel n`

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
  for i in 0..2: c[i] =
    uint8(round(factor.float * c[i].float / 255.0) * float(255'u8 div factor))

func filterGreyscale*(image: var Image) =
    for pixel in image.data.mitems:
      pixel.all = uint8 round(pixel.r.float * 0.2126 +
                              pixel.g.float * 0.7152 +
                              pixel.b.float * 0.0722)

func filterNegative*(image: var Image) =
    for pixel in image.data.mitems:
      for value in pixel.mitems: value = 255'u8 - value

func filterSepia*(image: var Image) =
    for pixel in image.data.mitems:
      let prev = pixel
      pixel.r = uint8 min(prev.r.float * 0.393 + prev.g.float * 0.769 + prev.b.float * 0.189, 255)
      pixel.g = uint8 min(prev.r.float * 0.349 + prev.g.float * 0.686 + prev.b.float * 0.168, 255)
      pixel.b = uint8 min(prev.r.float * 0.272 + prev.g.float * 0.534 + prev.b.float * 0.131, 255)
