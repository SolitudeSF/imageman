# Imageman
Rudimentary image manipulation (((framework)))

Some things may or may not work correctly.

Some example usage in tests.

## Why
To have some boilerplate for recreative programming with images.

## Projects using imageman

[diffimg](https://github.com/SolitudeSF/diffimg) - image diffing tool and library.

[blurhash](https://github.com/SolitudeSF/blurhash) - blurhash algorith implementation.

## Installation
`nimble install imageman`

## Features
- Easy manipulation of individual pixel components
- Image loading/saving
    - [x] PNG
    - [X] JPG
    - [x] BMP
    - [x] TGA
    - [ ] FF
- Color modes
    - [x] `ColorRGBU` - 8bit uint 3 components
    - [x] `ColorRGBAU` - 8bit uint 4 components
    - [x] `ColorRGBF` - 32bit float 3 components
    - [x] `ColorRGBAF` - 32bit float 4 components
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
