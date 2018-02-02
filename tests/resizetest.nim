import ../imagehelpers/[base, resize]

let
  image = loadImage "image.png"
  down = image.resizedNearestNeighbor(1010, 777)
  up = image.resizedNearestNeighbor(0.666, 1.488)

down.saveImage "down.png"
up.saveImage "up.png"
