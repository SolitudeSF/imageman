# Imageman
Rudimentary image manipulation framework.

Some things may or may not work correctly.

Check examples directory for short demonstration.

## Why
~~To have some boilerplate for recreational programming with images.~~
Manipulate. Images.

## Projects using imageman

[diffimg](https://github.com/SolitudeSF/diffimg) - image diffing tool and library.

[blurhash](https://github.com/SolitudeSF/blurhash) - blurhash algorith implementation.

## Installation
`nimble install imageman`

## Backends
### libjpeg(-turbo)
- Activated with `imagemanLibjpeg` flag. Enabled by default.
- SIMD accelerated JPEG encoder/decoder.
- Dynamically linked. Requires dll/so/dylib at runtime.

### libpng
- Activated with `imagemanLibpng` flag. Enabled by default.
- Fast PNG encoder/decoder (outperforms `stb_image`).
- Dynamically linked. Requires dll/so/dylib of itself and zlib at runtime.

### stb_image
- Activated with `imagemanStb` flag. By default only enabled if libjpeg and libpng are disabled.
- Supports reading and writing PNG, JPEG, BMP and TGA images but with limited control.
- Header only - compiled in.

## Features
- Easy manipulation of individual pixel components
- Image reading/writing
    - [x] PNG using `libpng`
    - [X] JPG using `libjpeg(-turbo)`
    - [x] BMP
    - [x] TGA
- Color modes
    - [x] `ColorRGBU` - 8bit uint 3 components
    - [x] `ColorRGBAU` - 8bit uint 4 components
    - [x] `ColorRGBF` - 32bit float 3 components
    - [x] `ColorRGBAF` - 32bit float 4 components
    - [x] `ColorRGBF64` - 64bit float 3 components
    - [x] `ColorRGBAF64` - 64bit float 4 components
    - [x] `ColorHSL` - 32bit float
    - [x] `ColorHSLuv` - 64bit float, perceptually uniform, unlike normal HSL
    - [x] `ColorHPLuv` - 64bit float
    RGB float components have valid range from 0 to 1.
    Hue range is 0..360. Saturation/Lightness range from 0 to 1.
- Filtering
    - [x] General convolutional kernel routine
        - [x] Smoothing
        - [x] Sharpening
        - [x] Edge detection
        - [x] Blur
    - [x] Greyscale
    - [x] Negative
    - [x] Sepia
    - [x] Quantization
- Dithering
    - [x] Some kernels
- Resizing
    - [x] Nearest neighbour
    - [x] Bilinear
    - [x] Trilinear
    - [x] Bicubic
    - [ ] Lanczos
    - [ ] Catmull-Rom
    - [ ] Cubic Hermite
- Drawing
    - [x] Line
    - [x] Circle
    - [ ] Ellipse
    - [ ] Bezier curve
- Rotating
    - [x] Vertically, Horizontally
    - [ ] Radial
- Documentation

## Examples
See [examples](./examples) directory.
