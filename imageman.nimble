import os

# Package

version = "0.7.6"
author = "SolitudeSF"
description = "Image manipulation library"
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 1.2.0"
requires "stb_image >= 2.2"

task examples, "Run examples":
  withDir "examples":
    let srcs = ["resize.nim", "flip.nim"]
    for src in srcs:
      echo "Run: " & src & " example"
      exec "nim c -r --hints:off --verbosity:0 " & src

task docgen, "Generate documentation":
  exec "rm -rf htmldocs"
  exec "nim doc --project --index:on --outdir:htmldocs src/imageman.nim"
  exec "cd htmldocs; nim buildIndex htmlDocs; mv imageman.html index.html"
