import ../src/imagehelpers/[images, drawing]

#var image = newImage(1000, 1000)
#image.drawCircle(200, 200, 150)
#image.saveFF "test.ff"
var image = loadFF "test.ff"
image.savePNG "test.png"
