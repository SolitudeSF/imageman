# Package

version       = "0.0.1"
author        = "SolitudeSF"
description   = "Image manipulation helper functions"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.2"
requires "nimPNG"

skipDirs = @["tests"]

task test, "run all tests":
  exec "nim c -r tests/imageloading"
  exec "nim c -r tests/filters"

task imageloading, "test creating and loading of images":
  exec "nim c -r tests/imageloading"

task filters, "test filters":
  exec "nim c -r tests/filters"
