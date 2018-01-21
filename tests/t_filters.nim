import ../imagehelpers/[base, filters]
echo "started"
var image = newImage(1000, 1000)
echo "image created"
image.filterSharpen
