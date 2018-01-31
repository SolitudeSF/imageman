import ../imagehelpers/[base, drawing]
var image = loadImage "image.png"
image.drawCircle(100, 100, 50)
image.saveImage "circle.png"
