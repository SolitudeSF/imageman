import ./images, ./colors
import math

func resizedNN*[T: Color](img: Image[T], w, h: int): Image[T] =
  result = initImage[T](w, h)
  let
    xr = img.w.float / w.float
    yr = img.h.float / h.float
  for j in 0..<h:
    let y = int(j.float * yr) * img.w
    let j = j * w
    for i in 0..<w:
      let x = int(i.float * xr)
      result[i + j] = img[x + y]

func resizedNN*[T: Color](img: Image[T], w, h: float): Image[T] =
  result = initImage[T](int(img.w.float * w), int(img.h.float * h))
  for j in 0..<result.h:
    let y = int(j.float / h) * img.w
    let j = j * result.w
    for i in 0..<result.w:
      let x = int(i.float / w)
      result[i + j] = img[x + y]

func resizedNNi*[T: Color](img: Image[T], w, h: int): Image[T] =
  result = initImage[T](w, h)
  let
    xr = (img.w shl 16) div w
    yr = (img.h shl 16) div h
  for j in 0..<h:
    let y = ((j * yr) shr 16) * img.w
    let j = j * w
    for i in 0..<w:
      let x = (i * xr) shr 16
      result[i + j] = img[x + y]

func resizedBilinear*[T: Color](img: Image[T], w, h: int): Image[T] =
  result = initImage[T](w, h)
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
      for t in 0..T.len - 1:
        result[i + j * w][t] = (T.componentType) (
          a[t].precise * (1 - xd) * (1 - yd) +
          b[t].precise *      xd  * (1 - yd) +
          c[t].precise * (1 - xd) *      yd  +
          d[t].precise *      xd  *      yd)

func resizedTrilinear*[T: Color](img: Image[T], w, h: int): Image[T] =
  result = initImage[T](w, h)
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

func cubicFilter(a, b, c: float): float {.inline.} =
  let x = abs a
  if x < 1:
    ((12 - 9*b - 6*c) * x * x * x + (12*b + 6*c - 18) * x * x + 6 - b - b) / 6
  elif x < 2:
    ((6*b + 30*c) * x * x - (b + 6*c) * x * x * x - (12*b + 48*c) * x + 8*b + 24*c) / 6
  else: 0

func resizedBicubic*[T: Color](img: Image[T], w, h: int, b = 1.0, c = 0.0): Image[T] =
  result = initImage[T](w, h)
  let
    xr = img.w.float / w.float
    yr = img.h.float / h.float
  for j in 0..<h:
    let
      oy = int(yr * j.float)
      dy = yr * j.float - oy.float
      jw = j * w
    for i in 0..<w:
      let
        ox = int(xr * i.float)
        dx = xr * i.float - ox.float
      var nr, ng, nb: T.componentType
      for m in -1..2:
        let
          bmdx = cubicFilter(m.float - dx, b, c)
          oxm = ox + m
        for n in -1..2:
          let oyn = oy + n
          if (oxm >= 0 and oyn >= 0 and oxm < img.w and oyn < img.h):
            let
              bdyn = cubicFilter(dy - n.float, b, c)
              p = img[oxm, oyn]
            nr += (T.componentType) (p.r.precise * bmdx * bdyn)
            ng += (T.componentType) (p.g.precise * bmdx * bdyn)
            nb += (T.componentType) (p.b.precise * bmdx * bdyn)
      let coord = i + jw
      result[coord].r = nr
      result[coord].g = ng
      result[coord].b = nb
      when T is ColorA:
        result[coord].a = img[int(i.float * xr), int(j.float * yr)].a
