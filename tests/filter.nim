import ../imagehelpers/[base, filters]
var image = loadImage "image.png"
image.filterEdgeDetection
image.saveImage "filtered.png"
