import ../src/imagehelpers/[images, drawing, filters]
var image = loadPNG "image.png"
image.filterSharpening
image.drawCircle(400, 400, 200)
image.savePNG "result.png"
