import ../src/imageman/[images, drawing, filters, dither]
import os
setCurrentDir getAppDir()
let data = readFile "image.png"
var image = loadImageFromMemory(cast[seq[byte]](data))
image.dither burkeDist
image.filterBoxBlur
image.drawCircle(400, 400, 200)
image.copyRegion(image.w - 500, image.h - 500, 500, 500).savePNG("region.png")
let outdata = image.writePNG
"result.png".writeFile cast[string](outdata)
