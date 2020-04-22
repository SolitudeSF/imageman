import ../colors, ./imagetype

const
  imagemanLibjpeg {.booldefine.} = true
  imagemanLibpng {.booldefine.} = true
  imagemanStb {.booldefine.} = not (imagemanLibjpeg or imagemanLibpng)

when not (imagemanLibjpeg or imagemanLibpng or imagemanStb):
  {.warning: "No IO backends activated."}


func startsWith[N: static int](data: openArray[char], val: array[N, byte]): bool =
  if data.len > N:
    for i in 0..<N:
      if val[i] != data[i].byte:
        return false
    return true

proc startsWith[N: static int](file: File, val: array[N, byte]): bool =
  var a: array[N, byte]
  discard file.readBytes(a, 0, N)
  file.setFilePos 0
  a == val

when imagemanLibjpeg:
  {.hint: "imageman libjpeg backend active"}
  import ./libjpeg
  export saveJPEG, writeJPEG
  const jpegMagic = [0xff'u8, 0xd8, 0xff]

when imagemanLibpng:
  {.hint: "imageman libpng backend active"}
  import ./libpng
  export savePNG, writePNG, JpegDCTMethod
  const pngMagic = [0x89'u8, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]

when imagemanStb:
  {.hint: "imageman stb_image backend active"}
  import ./stbi
  export saveBMP, saveTGA, writeBMP, writeTGA
  when not imagemanLibjpeg:
    export saveJPEG, writeJPEG
  when not imagemanLibpng:
    export savePNG, writePNG

template readImageImplMeta(n, t): untyped {.dirty.} =
  template readImageImpl(source: typed): untyped =
    when imagemanLibpng:
      if source.startsWith pngMagic:
        return readPNG[T](source)
    when imagemanLibjpeg:
      if source.startsWith jpegMagic:
        return readJPEG[T](source, jpegDCTMethod, jpegFancyUpsampling, jpegBlockSmoothing)
    when imagemanStb:
      return stbi.readImage[T](source)
    else:
      raise newException(CatchableError, "Unknown filetype")

  when imagemanLibjpeg:
    proc readImage*[T: Color](n: t,
      jpegDCTMethod = jDCTmISlow,
      jpegFancyUpsampling = false,
      jpegBlockSmoothing = true
    ): Image[T] =
      readImageImpl n
  else:
    proc readImage*[T: Color](n: t): Image[T] =
      readImageImpl n

readImageImplMeta file, File
readImageImplMeta data, openArray[char]

proc loadImage*[T: Color](path: string): Image[T] =
  let file = open(path, fmRead)
  defer: close file
  result = backends.readImage[T](file)
