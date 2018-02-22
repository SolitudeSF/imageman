import ../src/imagehelperspkg/[base, resize]

let
  image = loadImage "image.png"
  down = image.resizedNN(1010, 777)
  up = image.resizedNN(0.666, 1.488)
  bil = image.resizedBilinear(2000, 600)
  tril = image.resizedTrilinear(1000, 2000)
  cub = image.resizedBicubic(2000, 2000)

down.saveImage "down.png"
up.saveImage "up.png"
bil.saveImage "bil.png"
tril.saveImage "tril.png"
cub.saveImage "cub.png"
