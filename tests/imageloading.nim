import ../imagehelpers/base
import typetraits

var
  image = newImage(1000, 1000, transparent.removeAlpha)
  image4 = newImage(1000, 1000, white.addAlpha)
  transp = loadImage3 "transparent.png"
  trans = loadImage4 "transparent.png"

echo name(type(image))
echo name(type(image4))
echo name(type(transp[0]))
echo name(type(trans[0]))
