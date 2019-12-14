import ../src/imageman/[images, colors, drawing, filters, dither, resize, crop]
import os, strformat, unittest

setCurrentDir getAppDir()

const
  testDir = "tests"

suite "func cropped":
  setup:
    # sample.png is 20x20 pixel.
    let img = loadImage[ColorRGBU]("sample.png")
  test "Normal params":
    let params = [
        (x: 0, y: 0, w: 20, h: 20),
        (x: 0, y: 0, w: 10, h: 10),
        (x: 5, y: 0, w: 10, h: 10),
        (x: 0, y: 5, w: 10, h: 10),
        (x: 5, y: 5, w: 10, h: 10),
        (x: 10, y: 0, w: 10, h: 10),
        (x: 0, y: 10, w: 10, h: 10),
        (x: 10, y: 10, w: 10, h: 10),
        ]
    for p in params:
      let img2 = img.cropped(p.x, p.y, p.w, p.h)
      img2.savePNG(&"out_x{p.x:>03}_y{p.y:>03}_w{p.w:>03}_h{p.h:>03}.png")
  test "Illegal params":
    let params = [
        (x: 0, y: 0, w: 50, h: 50),
        (x: -1, y: 0, w: 10, h: 10),
        (x: 0, y: -1, w: 10, h: 10),
        ]
    for p in params:
      let img2 = img.cropped(p.x, p.y, p.w, p.h)
      img2.savePNG(&"out_x{p.x:>03}_y{p.y:>03}_w{p.w:>03}_h{p.h:>03}.png")
