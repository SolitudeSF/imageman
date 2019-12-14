import imageman

let img = loadImage[ColorRGBU]("sample.png")

let img2 = img.cropped(10, 10, 50, 80)
img2.savePNG("out_crop.png")

