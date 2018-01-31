import ../imagehelpers/base

var
  image = newImage(1000, 1000)
  trans = loadImage "image.png"

trans.saveImage "transparent.png"
image.saveImage "empty.png"
