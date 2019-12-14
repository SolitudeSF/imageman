import imageman

let img = loadImage[ColorRGBU]("sample.png")
let img2 = img.resizedBicubic(512, 512)
img2.savePNG("out_resize_bicubic.png")
