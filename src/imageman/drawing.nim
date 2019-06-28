import images, colors
import math

func draw*(i: var Image, x, y: int, c: Color) =
  if (x,y) in i: i[x, y] = c

func draw*(i: var Image, p: Point, c: Color) =
  if p in i: i[p] = c

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

func drawCircle*(i: var Image, x0, y0, r: int, c = black) =
  for point in circle(x0, y0, r):
    i.draw(point, c)

func drawCircle*(i: var Image, a: Point, r: int, c = black) =
  for point in circle2(a.x, a.y, r):
    i.draw(point, c)

func drawFilledCircle*(i: var Image, a: Point, r: int, c = black) =
  for x in a.x-r..a.x+r:
    for y in a.y-r..a.y+r:
      if (x-a.x)*(x-a.x)+(y-a.y)*(y-a.y) < r*r: i.draw((x,y), c)

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

func drawLine*(i: var Image, x0, y0, x1, y1: int, c = black) =
  for point in line(x0, y0, x1, y1):
    i.draw(point, c)

func drawLine*(i: var Image, a, b: Point, c = black) =
  for point in line(a.x, a.y, b.x, b.y):
    i.draw(point, c)

func drawPolyline*(i: var Image, closed = false, color = black, points: varargs[Point]) =
  for p in 1..points.high:
    i.drawLine(points[p-1], points[p], color)
  if closed: i.drawLine(points[^1], points[0], color)

func drawBrush*(i: var Image, a, b: Point, r = 10, c = black) =
  for point in line(a.x, a.y, b.x, b.y):
    i.drawFilledCircle(point, r, c)
