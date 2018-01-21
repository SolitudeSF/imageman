import ../imagehelpers/[base, filters]
var image = loadImage4 "image.png"
image.filterEdgeDetection
image.saveImage "filtered.png"
