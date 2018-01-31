import ../imagehelpers/base
import typetraits

var
  image = newImage(1000, 1000, transparent.withoutAlpha)
  image4 = newImage(1000, 1000, white.withAlpha)
  nontrans = loadImage3 "image.png"
  trans = loadImage4 "image.png"

echo name(type(image))
echo name(type(image4))
echo name(type(nontrans[0]))
echo name(type(trans[0]))

nontrans.saveImage "nontransparent.png"
trans.saveImage "transparent.png"
