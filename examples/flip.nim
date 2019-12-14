import imageman

let img = loadImage[ColorRGBU]("sample.png")

block:
  let img2 = img.flippedHoriz()
  img2.savePNG("out_flip_horiz.png")

block:
  let img2 = img.flippedVert()
  img2.savePNG("out_flip_vert.png")
