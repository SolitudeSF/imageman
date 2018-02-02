import base
import math

proc resizedNearestNeighbor*(img: Image, w, h: int): Image =
  result = newImage(h, w)
  let
    xr = img.w.float / w.float
    yr = img.h.float / h.float
  for j in 0..<h:
    let y = int(j.float * yr)
    for i in 0..<w:
      let x = int(i.float * xr)
      result[i, j] = img[x, y]

proc resizedNearestNeighbor*(img: Image, w, h: float): Image =
  result = newImage(int(img.h.float*h), int(img.w.float*w))
  for j in 0..<result.h:
    let y = int(j.float / h)
    for i in 0..<result.w:
      let x = int(i.float / w)
      result[i, j] = img[x, y]

proc resizedNearestNeighbor*(img: Image, r: float): Image = resizedNearestNeighbor(img, r, r)
