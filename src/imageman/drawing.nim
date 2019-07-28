import images, colors
import math

template circleRoutine: untyped =
  yield (x0 + x, y0 + y)
  yield (x0 + y, y0 + x)
  yield (x0 - y, y0 + x)
  yield (x0 - x, y0 + y)
  yield (x0 - x, y0 - y)
  yield (x0 - y, y0 - x)
  yield (x0 + y, y0 - x)
  yield (x0 + x, y0 - y)

iterator circle*(x0, y0, r: int): Point =
  var
    x = r - 1
    y = 0
    dx = 1
    dy = 1
    err = 1 - (r shl 1)
  while x>=y:
    circleRoutine()
    if err <= 0:
      y += 1
      err += dy
      dy += 2
    else:
      x -= 1
      dx += 2
      err += dx - (r shl 1)

iterator circle1*(x0, y0, r: int): Point =
  var
    x = 0
    y = r
    p = 1 - r
  while x < y:
    circleRoutine()
    inc x
    if p < 0:
      p += 2 * x + 1
    else:
      dec y
      p += 2 * (x - y) + 1

iterator circle2*(x0, y0, r: int): Point =
  var
    x = 0
    y = r
    d = (5 - r shl 2) shr 2
  while x <= y:
    circleRoutine()
    inc x
    if  d < 0:
      d += (x shl 1) + 1
    else:
      dec y
      d += (1 + x - y) shl 1

iterator circleBres*(x0, y0, r: int): Point =
  var
    x = 0
    y = r
    d = 3 - 2 * r

  while x <= y:
    circleRoutine()
    if d <= 0:
        d += 4 * x + 6
    else:
      d += 4 * (x - y) + 10
      y -= 1
    x += 1

func drawCircle*[T: Color](i: var Image[T], x0, y0, r: int, c: T) =
  for point in circle(x0, y0, r):
    i[point] = c

func drawCircle*[T: Color](i: var Image[T], a: Point, r: int, c: T) =
  for point in circle(a.x, a.y, r):
    i[point] = c

func drawFilledCircle*[T: Color](i: var Image[T], a: Point, r: int, c: T) =
  for y in a.y - r..a.y + r:
    let
      yw = y * i.w
      ya = (y - a.y) * (y - a.y)
      r2 = r * r
    for x in a.x - r..a.x + r:
      if (x - a.x) * (x - a.x) + ya < r2:
        i[yw + x] = c

iterator line*(x0, y0, x1, y1: int): Point =
  var
    x0 = x0
    x1 = x1
    y0 = y0
    y1 = y1
  if x0 == x1:
    if y0 > y1: swap y0, y1
    for y in y0..y1: yield (x0, y)
  elif y0 == y1:
    if x0 > x1: swap x0, x1
    for x in x0..x1: yield (x, y0)
  else:
    let
      w = x1 - x0
      h = y1 - y0
      dx1 = w.sgn
      dy1 = h.sgn
    var
      dx2 = w.sgn
      dy2 = 0
      long = w.abs
      short = h.abs
    if long <= short:
      swap long, short
      dy2 = h.sgn
      dx2 = 0
    var num = long shr 2
    for i in 0..long:
      yield (x0, y0)
      num += short
      if num >= long:
        num -= long
        x0 += dx1
        y0 += dy1
      else:
        x0 += dx2
        y0 += dy2

func drawLine*[T: Color](i: var Image[T], x0, y0, x1, y1: int, c: T) =
  for point in line(x0, y0, x1, y1):
    i[point] = c

func drawLine*[T: Color](i: var Image[T], a, b: Point, c: T) =
  for point in line(a.x, a.y, b.x, b.y):
    i[point] = c

func drawPolyline*[T: Color](i: var Image[T], closed = false, c: T, points: varargs[Point]) =
  for p in 1..points.high:
    i.drawLine(points[p-1], points[p], c)
  if closed: i.drawLine(points[^1], points[0], c)

func drawBrush*[T: Color](i: var Image[T], a, b: Point, r = 10, c: T) =
  for point in line(a.x, a.y, b.x, b.y):
    i.drawFilledCircle(point, r, c)
