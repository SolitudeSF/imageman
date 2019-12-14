import images, colors

func cropped*[T: Color](img: Image[T], x, y, w, h: int): Image[T] =
  ## Returns cropped image.
  let x = if x < 0: 0 else: x
  let y = if y < 0: 0 else: y
  let w = if img.w < x + w: img.w - x else: w
  let h = if img.h < y + h: img.h - y else: h
  result = initImage[T](w, h)
  for j in 0..<h:
    let y2 = (j + y) * img.w
    let j = j * w
    for i in 0..<w:
      let x2 = i + x
      result[i + j] = img[x2 + y2]
