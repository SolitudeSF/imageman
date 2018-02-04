import base
import math

proc resizedNN*(img: Image, w, h: int): Image =
  result = newImage(w, h)
  let
    xr = img.w.float / w.float
    yr = img.h.float / h.float
  for j in 0..<h:
    let y = int(j.float * yr)
    for i in 0..<w:
      let x = int(i.float * xr)
      result[i, j] = img[x, y]

proc resizedNN*(img: Image, w, h: float): Image =
  result = newImage(int(img.w.float*w), int(img.h.float*h))
  for j in 0..<result.h:
    let y = int(j.float / h)
    for i in 0..<result.w:
      let x = int(i.float / w)
      result[i, j] = img[x, y]

proc resizedNNi*(img: Image, w, h: int): Image =
  result = newImage(w, h)
  let
    xr = (img.w shl 16) div w
    yr = (img.h shl 16) div h
  for j in 0..<h:
    let y = (j * yr) shr 16
    for i in 0..<w:
      let x = (i * xr) shr 16
      result[i, j] = img[x, y]

proc resizedBilinear*(img: Image, w, h: int): Image =
  result = newImage(w, h)
  let
    xr = (img.w - 1).float / w.float
    yr = (img.h - 1).float / h.float
  for j in 0..<h:
    let
      y = int(yr * j.float)
      yd = (yr * j.float) - y.float
    for i in 0..<w:
      let
        x = int(xr * i.float)
        xd = (xr * i.float) - x.float
        id = x + y * img.w
        a = img[id]
        b = img[id + 1]
        c = img[id + img.w]
        d = img[id + img.w + 1]
      for t in 0..3:
        result[i + j * w] = uint8(a[t].float * (1 - xd) * (1 - yd) +
                                  b[t].float *      xd  * (1 - yd) +
                                  c[t].float * (1 - xd) *      yd  +
                                  d[t].float *      xd  *      yd)

proc resizedTrilinear*(img: Image, w, h: int): Image =
  result = newImage(w, h)
  var
    sech = img.h
    secw = img.w
  if img.h > h:
    while sech > h: sech = sech div 2
  else:
    while sech < h: sech = sech * 2
  if img.w > w:
    while secw > w: secw = secw div 2
  else:
    while secw < w: secw = secw * 2
  let
    first = img.resizedBilinear(w, h)
    second = img.resizedNN(secw, sech).resizedBilinear(w, h)
  for i in 0..<w*h:
    result.data[i] = interpolate(first.data[i], second.data[i], 0.5)

proc cubicFilter(a, b, c: float): float =
  let x = abs a
  if x < 1:
    ((12 - 9*b - 6*c) * pow(x, 3) + (12*b + 6*c - 18) * x * x + 6 - b - b) / 6
  elif x < 2:
    ((6*b + 30*c) * x * x - (b + 6*c) * pow(x, 3) - (12*b + 48*c) * x + 8*b + 24*c) / 6
  else: 0

proc resizedBicubic*(img: Image, w, h: int, B=1.0, C=0.0): Image =
  result = newImage(w, h)
  let
    xr = img.w.float / w.float
    yr = img.h.float / h.float
  for j in 0..<h:
    let
      oy = int(yr * j.float)
      dy = yr * j.float - oy.float
    for i in 0..<w:
      let
        ox = int(xr * i.float)
        dx = xr * i.float - ox.float
      var
        nr = 0
        ng = 0
        nb = 0
      for m in -1..2:
        let
          Bmdx = cubicFilter(m.float - dx, B, C)
          oxm = ox + m
        for n in -1..2:
          let oyn = oy + n
          if (oxm >= 0 and oyn >= 0 and oxm < img.w and oyn < img.h):
            let
              Bdyn = cubicFilter(dy - n.float, B, C)
              p = img[oxm, oyn]
            nr += int(p.r.float * Bmdx * Bdyn)
            ng += int(p.g.float * Bmdx * Bdyn)
            nb += int(p.b.float * Bmdx * Bdyn)
      result[i, j] = [uint8 nr, uint8 ng, uint8 nb, img[int(i.float * xr), int(j.float * yr)].a]
