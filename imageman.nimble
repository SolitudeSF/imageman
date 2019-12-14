# Package

version       = "0.6.3"
author        = "SolitudeSF"
description   = "Image manipulation library"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.20.0"
requires "stb_image >= 2.2"

task examples, "Run examples":
  withDir "examples":
    let srcs = ["resize.nim", "flip.nim"]
    for src in srcs:
      echo "Run: " & src & " example"
      exec "nim c -r --hints:off --verbosity:0 " & src
