import ../src/imagehelpers/[images, drawing, filters, dither]
var image = loadPNG "image.png"
image.filterBoxBlur
image.dither burkeDist
image.drawCircle(400, 400, 200)
image.savePNG "result.png"
