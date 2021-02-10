import math, random, typetraits

type
  ColorComponent* = uint8 | float32 | float64
  ColorRGBU* = distinct array[3, uint8] ## RGB range 0..255
  ColorRGBAU* = distinct array[4, uint8] ## RGB range 0..255
  ColorRGBF* = distinct array[3, float32] ## RGB range 0..1
  ColorRGBAF* = distinct array[4, float32] ## RGB range 0..1
  ColorRGBF64* = distinct array[3, float64] ## RGB range 0..1
  ColorRGBAF64* = distinct array[4, float64] ## RGB range 0..1
  ColorHSL* = distinct array[3, float32] ## Hue 0..360, Sat/Light 0..1
  ColorHSLuv* = distinct array[3, float64] ## Hue 0..360, Sat/Light 0..1
  ColorHPLuv* = distinct array[3, float64] ## Hue 0..360, Sat/Light 0..1
  ColorGU* = distinct array[1, uint8]
  ColorGAU* = distinct array[2, uint8]
  ColorGF* = distinct array[1, float32]
  ColorGAF* = distinct array[2, float32]
  ColorGF64* = distinct array[1, float64]
  ColorGAF64* = distinct array[2, float64]
  ColorGUAny* = ColorGU | ColorGAU
  ColorGFAny* = ColorGF | ColorGAF
  ColorGF64Any* = ColorGF64 | ColorGAF64
  ColorGAny = ColorGUAny | ColorGFAny | ColorGF64Any
  ColorRGBUAny* = ColorRGBU | ColorRGBAU
  ColorRGBFAny* = ColorRGBF | ColorRGBAF
  ColorRGBF64Any* = ColorRGBF64 | ColorRGBAF64
  ColorRGBAny* = ColorRGBUAny | ColorRGBFAny | ColorRGBF64Any
  ColorA* = ColorRGBAU | ColorRGBAF | ColorRGBAF64 | ColorGAU | ColorGAF | ColorGAF64
  Color* = ColorRGBAny | ColorGAny | ColorHSL | ColorHSLuv | ColorHPLuv

const
  hsluvM = [
    (3.24096994190452134377, -1.53738317757009345794, -0.49861076029300328366),
    (-0.96924363628087982613, 1.87596750150772066772, 0.04155505740717561247),
    (0.05563007969699360846, -0.20397695888897656435, 1.05697151424287856072)
  ]
  hsluvMInv = [
    (0.41239079926595948129, 0.35758433938387796373, 0.18048078840183428751),
    (0.21263900587151035754, 0.71516867876775592746, 0.07219231536073371500),
    (0.01933081871559185069, 0.11919477979462598791, 0.95053215224966058086)
  ]
  refU = 0.19783000664283680764
  refV = 0.46831999493879100370
  kappa = 903.29629629629629629630
  epsilon = 0.00885645167903563082
  err = 0.00000001
  uperr = 100 - err

template `[]`*[T: Color](c: T, n: Ordinal): auto = distinctBase(c)[n]
template `[]=`*[T: Color](c: var T, n: Natural, v) = distinctBase(c)[n] = v
template len*(c: typedesc[Color]): int = distinctBase(c).len
template len*(c: Color): int = distinctBase(c).len
template high*(c: typedesc[Color]): int = distinctBase(c).high
template high*(c: Color): int = distinctBase(c).high
template `==`*[T: Color](x, y: T): bool = distinctBase(x) == distinctBase(y)

template r*(c: ColorRGBAny): untyped = c[0]
template g*(c: ColorRGBAny): untyped = c[1]
template b*(c: ColorRGBAny): untyped = c[2]
template a*(c: ColorA): untyped = c[3]
template `r=`*(c: var ColorRGBAny, i: untyped) = c[0] = i
template `g=`*(c: var ColorRGBAny, i: untyped) = c[1] = i
template `b=`*(c: var ColorRGBAny, i: untyped) = c[2] = i
template `a=`*(c: var ColorA, i: untyped) = c[3] = i
template h*(c: ColorHSL): float32 = c[0]
template s*(c: ColorHSL): float32 = c[1]
template l*(c: ColorHSL): float32 = c[2]
template `h=`*(c: var ColorHSL, i: float32) = c[0] = i
template `s=`*(c: var ColorHSL, i: float32) = c[1] = i
template `l=`*(c: var ColorHSL, i: float32) = c[2] = i
template h*(c: ColorHSLuv | ColorHPLuv): float64 = c[0]
template s*(c: ColorHSLuv): float64 = c[1]
template p*(c: ColorHPLuv): float64 = c[1]
template l*(c: ColorHSLuv | ColorHPLuv): float64 = c[2]
template `h=`*(c: var (ColorHSLuv | ColorHPLuv), i: float64) = c[0] = i
template `s=`*(c: var ColorHSLuv, i: float64) = c[1] = i
template `p=`*(c: var ColorHPLuv, i: float64) = c[1] = i
template `l=`*(c: var (ColorHSLuv | ColorHPLuv), i: float64) = c[2] = i

template componentType*(t: typedesc[Color]): typedesc =
  ## Returns component type of a given color type.
  when t is ColorRGBFAny | ColorHSL:
    float32
  elif t is ColorRGBF64Any | ColorHSLuv | ColorHPLuv:
    float64
  else:
    uint8

template hasAlpha*(t: typedesc[Color]): bool = t is ColorA

template iteratorImpl[T: Color](c: T): untyped =
  when T is ColorRGBAny:
    yield c.r
    yield c.g
    yield c.b
  elif T is (ColorHSL | ColorHSLuv):
    yield c.h
    yield c.s
    yield c.l
  elif T is ColorHPLuv:
    yield c.h
    yield c.p
    yield c.l
  when T is ColorA:
    yield c.a

iterator items*[T: Color](c: T): T.componentType = iteratorImpl[T](c)
iterator mitems*[T: Color](c: var T): var T.componentType = iteratorImpl[T](c)

template maxComponentValue*(t: typedesc[ColorRGBAny]): untyped =
  ## Returns maximum component value of a give color type.
  when t is ColorRGBFAny:
    1.0'f32
  elif t is ColorRGBF64Any:
    1.0'f64
  else:
    255'u8

template precise*[T: ColorComponent](t: T): untyped =
  ## Converts component to float32 if it isn't.
  when T is uint8:
    t.float32
  else:
    t

template precise*[T: ColorComponent](t: typedesc[T]): typedesc =
  ## Converts component to float32 if it isn't.
  when T is uint8:
    float32
  else:
    t

func toFloat32*(c: uint8): float32 =
  ## Converts 0..255 uint8 to 0..1 float32
  c.float32 / 255

func toFloat64*(c: uint8): float64 =
  ## Converts 0..255 uint8 to 0..1 float32
  c.float64 / 255

func toUint8*(c: float32 | float64): uint8 =
  ## Converts 0..1 float to 0..255 uint8
  uint8(c * 255)

# HSLuv helpers
func toXYZ(c: float64): float64 =
  if c > 0.04045:
    pow((c + 0.055) / 1.055, 2.4)
  else:
    c / 12.92

func dotProduct[T](a, b: (T, T, T)): T =
  a[0] * b[0] + a[1] * b[1] + a[2] * b[2]

func toXYZ(c: ColorRGBF64): tuple[x, y, z: float64] =
  let t = (c.r.toXYZ, c.g.toXYZ, c.b.toXYZ)
  result.x = dotProduct(hsluvMInv[0], t)
  result.y = dotProduct(hsluvMInv[1], t)
  result.z = dotProduct(hsluvMInv[2], t)

func y2l(y: float64): float64 =
  if y <= epsilon:
    y * kappa
  else:
    116.0 * cbrt(y) - 16.0

func toLUV(c: tuple[x, y, z: float64]): tuple[l, u, v: float64] =
  let
    varU = (4.0 * c.x) / (c.x + (15.0 * c.y) + (3.0 * c.z))
    varV = (9.0 * c.y) / (c.x + (15.0 * c.y) + (3.0 * c.z))

  result.l = c.y.y2l
  if result.l >= err:
    result.u = 13.0 * result.l * (varU - refU)
    result.v = 13.0 * result.l * (varV - refV)

func toLCH(c: tuple[l, u, v: float64]): tuple[l, c, h: float64] =
  let s = sqrt(c.u * c.u + c.v * c.v)
  if s >= err:
    result.h = arctan2(c.v, c.u) * 57.29577951308232087680
    if result.h < 0.0:
      result.h += 360.0
  result.l = c.l
  result.c = s

func getBounds(l: float64): array[6, tuple[a, b: float64]] =
  let
    tl = l + 16.0
    sub1 = (tl * tl * tl) / 1560896.0
    sub2 = if sub1 > epsilon: sub1 else: l / kappa

  for channel in 0..2:
    let
      m1 = hsluvM[channel][0]
      m2 = hsluvM[channel][1]
      m3 = hsluvM[channel][2]
    for t in 0..1:
      let
        top1 = (284517.0 * m1 - 94839.0 * m3) * sub2
        top2 = (838422.0 * m3 + 769860.0 * m2 + 731718.0 * m1) * l * sub2 - 769860.0 * t.float64 * l
        bottom = (632260.0 * m3 - 126452.0 * m2) * sub2 + 126452.0 * t.float64

      result[channel * 2 + t] = (top1 / bottom, top2 / bottom)

func rayLengthUntilIntersect(theta: float64, line: tuple[a, b: float64]): float64 =
  line.b / (sin(theta) - line.a * cos(theta))

func maxChromaForLH(l, h: float64): float64 =
  result = float64.high
  let
    hrad = h * 0.01745329251994329577
    bounds = getBounds(l)
  for i in 0..5:
    let len = rayLengthUntilIntersect(hrad, bounds[i])
    if len >= 0 and len < result:
      result = len

func toHSLuv(c: tuple[l, c, h: float64]): ColorHSLuv =
  if c.l in err..uperr:
    result.s = c.c / maxChromaForLH(c.l, c.h)
  if c.c >= err:
    result.h = c.h
  result.l = c.l / 100

func toLCH(c: ColorHSLuv): tuple[l, c, h: float64] =
  result.l = c.l * 100
  if result.l in err..uperr:
    result.c = maxChromaForLH(result.l, c.h) * c.s
  if c.s * 100 >= err:
    result.h = c.h

func toLUV(c: tuple[l, c, h: float64]): tuple[l, u, v: float64] =
  let hrad = c.h * 0.01745329251994329577
  result = (c.l, cos(hrad) * c.c, sin(hrad) * c.c)

func l2y(l: float64): float64 =
  if l <= 8.0:
    l / kappa
  else:
    let x = (l + 16.0) / 116.0
    x * x * x

func toXYZ(c: tuple[l, u, v: float64]): tuple[x, y, z: float64] =
  if c.l > err:
    let
      varU = c.u / (13.0 * c.l) + refU
      varV = c.v / (13.0 * c.l) + refV
    result.y = l2y(c.l)
    result.x = -(9.0 * result.y * varU) / ((varU - 4.0) * varV - varU * varV);
    result.z = (9.0 * result.y - (15.0 * varV * result.y) - (varV * result.x)) / (3.0 * varV);

func fromXYZ(c: float64): float64 =
  if c <= 0.0031308:
    12.92 * c
  else:
    1.055 * pow(c, 1.0 / 2.4) - 0.055

func toRGB(c: tuple[x, y, z: float64]): ColorRGBF64 =
  result.r = fromXYZ(dotProduct(hsluvM[0], c))
  result.g = fromXYZ(dotProduct(hsluvM[1], c))
  result.b = fromXYZ(dotProduct(hsluvM[2], c))

func intersect(a, b: tuple[a, b: float64]): float64 =
  (a.b - b.b) / (b.a - a.a)

func distFromPoleSquared(a, b: float64): float64 =
  a * a + b * b

func maxSafeChromaForL(l: float64): float64 =
  result = float64.high
  let bounds = getBounds(l)
  for i in 0..5:
    let
      m1 = bounds[i].a
      b1 = bounds[i].b
      line2 = (-1.0 / m1, 0.0)
      x = intersect(bounds[i], line2)
      distance = distFromPoleSquared(x, b1 + x * m1)
    if distance < result:
      result = distance
  result = sqrt result

func toHPLuv(c: tuple[l, c, h: float64]): ColorHPLuv =
  if c.l in err..uperr:
    result.p = c.c / maxSafeChromaForL(c.l)
  if c.c >= err:
    result.h = c.h
  result.l = c.l / 100

func toLCH(c: ColorHPLuv): tuple[l, c, h: float64] =
  result.l = c.l * 100
  if result.l in err..uperr:
    result.c = maxSafeChromaForL(result.l) * c.p
  if c.p * 100 >= err:
    result.h = c.h

#[
to/from|RGBU|RGBAU|RGBF|RGBAF|RGBF64|RGBAF64|HSL|HSLuv|HPLuv|
RGBU   |*   |+    |+   |+    |+     |+      |   |     |     |
RGBAU  |+   |*    |+   |+    |+     |+      |   |     |     |
RGBF   |+   |+    |*   |+    |+     |+      |+  |     |     |
RGBAF  |+   |+    |+   |*    |+     |+      |   |     |     |
RGBF64 |+   |+    |+   |+    |*     |+      |   |+    |+    |
RGBAF64|+   |+    |+   |+    |+     |*      |   |+    |+    |
HSL    |    |     |+   |     |      |       |*  |     |     |
HSLuv  |    |     |    |     |+     |+      |   |*    |     |
HPLuv  |    |     |    |     |+     |+      |   |     |*    |
]#

func to*[T: Color](c: T, t: typedesc[T]): T = c

func to*[T: ColorRGBU](c: ColorRGBAU, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBU

func to*[T: ColorRGBAU](c: ColorRGBU, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBU
  result.a = 255

func to*[T: ColorRGBF](c: ColorRGBAF, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBF

func to*[T: ColorRGBAF](c: ColorRGBF, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof ColorRGBF
  result.a = 1.0

func to*[T: ColorRGBUAny](c: ColorRGBFAny | ColorRGBF64Any, t: typedesc[T]): T =
  result.r = c.r.toUint8
  result.g = c.g.toUint8
  result.b = c.b.toUint8
  when T is ColorA:
    result.a = when c is ColorA: c.a.toUint8 else: 255

func to*[T: ColorRGBFAny](c: ColorRGBUAny, t: typedesc[T]): T =
  result.r = c.r.toFloat32
  result.g = c.g.toFloat32
  result.b = c.b.toFloat32
  when T is ColorA:
    result.a = when c is ColorA: c.a.toFloat32 else: 1.0

func to*[T: ColorRGBF64Any](c: ColorRGBUAny, t: typedesc[T]): T =
  result.r = c.r.toFloat64
  result.g = c.g.toFloat64
  result.b = c.b.toFloat64
  when T is ColorA:
    result.a = when c is ColorA: c.a.toFloat64 else: 1.0

func to*[T: ColorRGBF](c: ColorHSL, t: typedesc[T]): T =
  let a = c.s * min(c.l, 1 - c.l)

  template f(n: float32): float32 =
    let k = (n + c.h / 30) mod 12
    c.l - a * max(-1, min(1, min(k - 3, 9 - k)))

  ColorRGBF [f 0, f 8, f 4]

func to*[T: ColorHSL](c: ColorRGBF, t: typedesc[T]): T =
  let
    minC = min(c.r, min(c.g, c.b))
    maxC = max(c.r, max(c.g, c.b))
    chroma = maxC - minC

  result.l = (minC + maxC) / 2

  if chroma == 0:
    result.h = 0
  elif maxC == c.r:
    result.h = (c.g - c.b) / chroma
  elif maxC == c.g:
    result.h = 2 + (c.b - c.r) / chroma
  elif maxC == c.b:
    result.h = 4 + (c.r - c.g) / chroma

  result.h = min(result.h * 60, 360)
  if result.h < 0:
    result.h += 360

  if chroma != 0:
    result.s = chroma / (1 - abs(2 * result.l - 1))

func to*[T: ColorRGBFAny](c: ColorRGBF64Any, t: typedesc[T]): T =
  result.r = c.r.float32
  result.g = c.g.float32
  result.b = c.b.float32
  when T is ColorA:
    result.a = when c is ColorA: c.a.float32 else: 1.0

func to*[T: ColorRGBF64Any](c: ColorRGBFAny, t: typedesc[T]): T =
  result.r = c.r.float64
  result.g = c.g.float64
  result.b = c.b.float64
  when T is ColorA:
    result.a = when c is ColorA: c.a.float64 else: 1.0

func to*[T: ColorRGBAF64](c: ColorRGBF64, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof c
  result.a = 1.0

func to*[T: ColorRGBF64](c: ColorRGBAF64, t: typedesc[T]): T =
  copyMem addr result, unsafeAddr c, sizeof T

func to*[T: ColorHSLuv](c: ColorRGBF64Any, t: typedesc[T]): T =
  c.toXYZ.toLUV.toLCH.toHSLuv

func to*[T: ColorRGBF64Any](c: ColorHSLuv, t: typedesc[T]): T =
  let r = c.toLCH.toLUV.toXYZ.toRGB
  when T is ColorA: r.to(ColorRGBAF64) else: r

func to*[T: ColorHPLuv](c: ColorRGBF64, t: typedesc[T]): T =
  c.toXYZ.toLUV.toLCH.toHPLuv

func to*[T: ColorRGBF64Any](c: ColorHPLuv, t: typedesc[T]): T =
  let r = c.toLCH.toLUV.toXYZ.toRGB
  when T is ColorA: r.to(ColorRGBAF64) else: r

func blendColorValue*[T: ColorComponent](a, b: T, t: float32): T {.inline.} =
  ## Blends two color with ratio.
  T sqrt((1.0 - t) * a.precise * a.precise + t * b.precise * b.precise)

func `+`*[T: Color](a, b: T): T =
  ## Blends two colors.
  result.r = blendColorValue(a.r, b.r, 0.3)
  result.g = blendColorValue(a.g, b.g, 0.3)
  result.b = blendColorValue(a.b, b.b, 0.3)
  when T is ColorA:
    result.a = a.a

func `$`*(c: ColorA): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ", a: " & $c.a & ")"

func `$`*(c: ColorRGBU | ColorRGBF | ColorRGBF64): string =
  "(r: " & $c.r & ", g: " & $c.g & ", b: " & $c.b & ")"

func `$`*(c: ColorHSL | ColorHSLuv): string =
  "(h: " & $c.h & ", s: " & $c.s & ", l: " & $c.l & ")"

func `$`*(c: ColorHPLuv): string =
  "(h: " & $c.h & ", p: " & $c.p & ", l: " & $c.l & ")"

func `~=`*[T: Color](a, b: T, e = componentType(T)(1.0e-11)): bool =
  ## Compares colors with given accuracy.
  abs(a[0] - b[0]) < e and abs(a[1] - b[1]) < e and abs(a[2] - b[2]) < e

proc rand(u: uint8): uint8 = uint8 u.int.rand
func rand(r: var Rand, u: uint8): uint8 = uint8 r.rand(u.int)

proc rand*[T: Color]: T =
  ## Returns random color.
  for c in result.mitems:
    c = typeof(c) rand(T.maxComponentValue)

func rand*[T: Color](r: var Rand): T =
  ## Returns random color.
  for c in result.mitems:
    c = typeof(c) r.rand(T.maxComponentValue)

func isGreyscale*(c: ColorRGBAny): bool =
  ## Checks if color is grayscale (all color components are equal).
  c.r == c.g and c.r == c.b

func interpolate*[T: Color](a, b: T, x: float32, L = 1.0): T =
  ## Returns linearly interpolated color value.
  result[0] = (T.componentType) (a[0].precise + x * (b[0].precise - a[0].precise) / L)
  result[1] = (T.componentType) (a[1].precise + x * (b[1].precise - a[1].precise) / L)
  result[2] = (T.componentType) (a[2].precise + x * (b[2].precise - a[2].precise) / L)
  when T is ColorA:
    result.a = (T.componentType) (a.a.precise + x * (b.a.precise - a.a.precise) / L)
