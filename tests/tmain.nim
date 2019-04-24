import ../src/imageman/[images, drawing, filters, dither]
import os
setCurrentDir getAppDir()
var image = loadPNG "image.png"
image.dither burkeDist
image.filterBoxBlur
image.drawCircle(400, 400, 200)
image.savePNG "result.png"
