import ./filters

const
  kernelSmoothing* = [1f, 1, 1,
                      1, 2, 1,
                      1, 1, 1].toKernel 3
  kernelSharpening* = [-1f, -1, -1,
                       -1,  9, -1,
                       -1, -1, -1].toKernel 3
  kernelSharpen* = [ 0f, -1,  0,
                    -1,  5, -1,
                     0, -1,  0].toKernel 3
  kernelEdgeDetection* = [ 1f, 0,-1,
                           0, 0, 0,
                          -1, 0, 1].toKernel 3
  kernelEdgeDetection2* = [0f, 1, 0,
                           1,-4, 1,
                           0, 1, 0].toKernel 3
  kernelEdgeDetection3* = [-1f, -1, -1,
                           -1,  8, -1,
                           -1, -1, -1].toKernel 3
  kernelRaised* = [0f, 0,-2,
                   0, 2, 0,
                   1, 0, 0].toKernel 3
  kernelBoxBlur* = [1f, 1, 1,
                    1, 1, 1,
                    1, 1, 1].toKernel 3
  kernelMotionBlur* = [0f, 0, 1,
                       0, 0, 0,
                       1, 0, 0].toKernel 3
  kernelGaussianBlur5* = [1f,  4,  6,  4, 1,
                          4, 16, 24, 16, 4,
                          6, 24, 36, 24, 6,
                          4, 16, 24, 16, 4,
                          1,  4,  6,  4, 1].toKernel 5
  kernelUnsharpMasking* = [1f,  4,   6,  4, 1,
                           4, 16,  24, 16, 4,
                           6, 24,-476, 24, 6,
                           4, 16,  24, 16, 4,
                           1,  4,   6,  4, 1].toKernel 5
  kernelEmboss* = [-2f, -1, 0,
                   -1,   1, 1,
                   0,    1, 2].toKernel 3
