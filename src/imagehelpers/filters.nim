import images, colors
import math, sequtils

const
  kernelSmoothing = @[@[1.0, 1.0, 1.0],
                      @[1.0, 2.0, 1.0],
                      @[1.0, 1.0, 1.0]]
  kernelSharpening = @[@[-1.0, -1.0, -1.0],
                       @[-1.0,  9.0, -1.0],
                       @[-1.0, -1.0, -1.0]]
  kernelSharpen = @[@[ 0.0, -1.0,  0.0],
                    @[-1.0,  5.0, -1.0],
                    @[ 0.0, -1.0,  0.0]]
  kernelEdgeDetection1= @[@[ 1.0, 0.0,-1.0],
                          @[ 0.0, 0.0, 0.0],
                          @[-1.0, 0.0, 1.0]]
  kernelEdgeDetection2 = @[@[0.0, 1.0, 0.0],
                           @[1.0,-4.0, 1.0],
                           @[0.0, 1.0, 0.0]]
  kernelEdgeDetection3 = @[@[-1.0, -1.0, -1.0],
                           @[-1.0,  8.0, -1.0],
                           @[-1.0, -1.0, -1.0]]
  kernelRaised = @[@[0.0, 0.0,-2.0],
                   @[0.0, 2.0, 0.0],
                   @[1.0, 0.0, 0.0]]
  kernelBoxBlur = @[@[1.0, 1.0, 1.0],
                    @[1.0, 1.0, 1.0],
                    @[1.0, 1.0, 1.0]]
  kernelMotionBlur = @[@[0.0, 0.0, 1.0],
                       @[0.0, 0.0, 0.0],
                       @[1.0, 0.0, 0.0]]
  kernelGaussianBlur5 = @[@[1.0,  4.0,  6.0,  4.0, 1.0],
                          @[4.0, 16.0, 24.0, 16.0, 4.0],
                          @[6.0, 24.0, 36.0, 24.0, 6.0],
                          @[4.0, 16.0, 24.0, 16.0, 4.0],
                          @[1.0,  4.0,  6.0,  4.0, 1.0]]
  kernelUnsharpMasking = @[@[1.0,  4.0,   6.0,  4.0, 1.0],
                           @[4.0, 16.0,  24.0, 16.0, 4.0],
                           @[6.0, 24.0,-476.0, 24.0, 6.0],
                           @[4.0, 16.0,  24.0, 16.0, 4.0],
                           @[1.0,  4.0,   6.0,  4.0, 1.0]]

proc applyKernel*(img: var Image, k: seq[seq[float]]) =
  let
    kh = k.len
    kw = k[0].len
  var
    denom = k.foldl(a + b.foldl(a + b), 0.0)
    temp = img
  if denom == 0: denom = 1
  for x in 0..img.w - kh:
    for y in 0..img.h - kw:
      var r, g, b = 0.0
      for j in 0..kh-1:
        for i in 0..kw-1:
          let
            rx = x + i
            ry = y + j
          r += img[rx, ry].r.float * k[i][j]
          g += img[rx, ry].g.float * k[i][j]
          b += img[rx, ry].b.float * k[i][j]
      temp[x,y].r = uint8 clamp(r / denom, 0, 255)
      temp[x,y].g = uint8 clamp(g / denom, 0, 255)
      temp[x,y].b = uint8 clamp(b / denom, 0, 255)
  img = temp

template filterSmoothing*(i: var Image) = i.applyKernel kernelSmoothing
template filterSharpening*(i: var Image) = i.applyKernel kernelSharpening
template filterSharpen*(i: var Image) = i.applyKernel kernelSharpen
template filterRaised*(i: var Image) = i.applyKernel kernelRaised
template filterEdgeDetection*(i: var Image) = i.applyKernel kernelEdgeDetection3
template filterBoxBlur*(i: var Image) = i.applyKernel kernelBoxBlur
template filterMotionBlur*(i: var Image) = i.applyKernel kernelMotionBlur
template filterGaussianBlur5*(i: var Image) = i.applyKernel kernelGaussianBlur5
template filterUnsharpMasking*(i: var Image) = i.applyKernel kernelUnsharpMasking

proc quantize*(c: var Color, factor: uint8) =
  for i in 0..2: c[i] =
    uint8(round(factor.float * c[i].float / 255.0) * float(255'u8 div factor))

proc filterGreyscale*(image: var Image) =
    for pixel in image.data.mitems:
      pixel.all = uint8 round(pixel.r.float * 0.2126 +
                              pixel.g.float * 0.7152 +
                              pixel.b.float * 0.0722)

proc filterNegative*(image: var Image) =
    for pixel in image.data.mitems:
      for value in pixel.mitems: value = 255'u8 - value

proc filterSepia*(image: var Image) =
    for pixel in image.data.mitems:
      let prev = pixel
      pixel.r = uint8 min(prev.r.float * 0.393 + prev.g.float * 0.769 + prev.b.float * 0.189, 255)
      pixel.g = uint8 min(prev.r.float * 0.349 + prev.g.float * 0.686 + prev.b.float * 0.168, 255)
      pixel.b = uint8 min(prev.r.float * 0.272 + prev.g.float * 0.534 + prev.b.float * 0.131, 255)
