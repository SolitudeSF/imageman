import ../src/imagehelperspkg/[base, drawing, filters]
var image = loadPNG "image.png"
image.filterEdgeDetection
image.drawCircle(400, 400, 200, blue)
image.savePNG "result.png"
