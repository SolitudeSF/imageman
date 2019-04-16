import ../src/imagehelpers/[images, resize]
import os
setCurrentDir getAppDir()

let
  image = loadPNG "image.png"
  down = image.resizedNN(1010, 777)
  up = image.resizedNN(0.666, 1.488)
  bil = image.resizedBilinear(2000, 600)
  tril = image.resizedTrilinear(1000, 2000)
  cub = image.resizedBicubic(2000, 2000)

down.savePNG "down.png"
up.savePNG "up.png"
bil.savePNG "bil.png"
tril.savePNG "tril.png"
cub.savePNG "cub.png"
