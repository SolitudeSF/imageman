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
  exec "nim c -d:debug -r tests/imageloading"
  exec "nim c -d:debug -r tests/t_filters"

task imageloading, "test creating and loading of images":
  exec "nim c -d:debug -r tests/imageloading"

task filters, "test filters":
  exec "nim c -d:debug -r tests/t_filters"
