import ../imagehelpers/[base, drawing, filters]
var image = loadImage "image.png"
image.filterEdgeDetection
image.drawCircle(400, 400, 200, blue)
image.saveImage "result.png"
