import ../src/imagehelpers/[images, drawing, filters, dither]
import os
setCurrentDir getAppDir()
var image = loadPNG "image.png"
image.filterBoxBlur
image.dither burkeDist
image.drawCircle(400, 400, 200)
image.savePNG "result.png"
