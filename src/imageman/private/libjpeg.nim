import ./imagetype, ../colors

when defined(windows):
  const libname = "libjpeg.dll"
elif defined(macos):
  const libname = "libjpeg.dylib"
else:
  const libname = "libjpeg.so(|.8)"

const
  JPEG_LIB_VERSION = 80
  NUM_QUANT_TBLS = 4
  NUM_HUFF_TBLS = 4
  NUM_ARITH_TBLS = 16
  MAX_COMPS_IN_SCAN = 4
  C_MAX_BLOCKS_IN_MCU = 10
  DCTSIZE2 = 64
  D_MAX_BLOCKS_IN_MCU = 10
  JMSG_STR_PARM_MAX = 80
  JMSG_LENGTH_MAX = 200

  after70 = JPEG_LIB_VERSION >= 70
  after80 = JPEG_LIB_VERSION >= 80

type
  JpegColorSpace {.size: 4.} = enum
    jcsUnknown
    jcsGrayscale
    jcsRGB
    jcsYCbCr
    jcsCMYK
    jcsYCCK
    jcsEXTRGB
    jcsEXTRGBX
    jcsEXTBGR
    jcsEXTBGRX
    jcsEXTXBGR
    jcsEXTXRGB
    jcsEXTRGBA
    jcsEXTBGRA
    jcsEXTABGR
    jcsEXTARGB
    jcsRGB565

  JpegDCTMethod* {.size: 4.} = enum
    jDCTmISlow
    jDCTmIFast
    jDCTmFloat

  JpegDitherMode {.size: 4.} = enum
    jdmNone
    jdmOrdered
    jdmFs

  JpegCommon = object
    err: ptr JpegErrorMgr
    mem, progress, clientData: pointer
    isDecompressor, globalInt: cint

  JpegCompress = object
    err: ptr JpegErrorMgr
    mem, progress, clientData: pointer
    isDecompressor, globalInt: cint
    dest: ptr JpegDestinationMgr
    imageWidth, imageHeight: cuint
    inputComponents: cint
    inColorSpace: JpegColorSpace
    inputGamma: cdouble
    when after70:
      scaleNum, scaleDenom: cuint
      jpegWidth, jpegHeight: cuint
    dataPrecision, numComponents: cint
    jpegColorSpace: JpegColorSpace
    jpegComponentInfo: pointer
    quantTblPtrs: array[NUM_QUANT_TBLS, pointer]
    when after70:
      qScaleFactor: array[NUM_QUANT_TBLS, cint]
    dcHuffTblPtrs: array[NUM_HUFF_TBLS, pointer]
    acHuffTblPtrs: array[NUM_HUFF_TBLS, pointer]
    arithDcL: array[NUM_ARITH_TBLS, cuchar]
    arithDcU: array[NUM_ARITH_TBLS, cuchar]
    arithAcK: array[NUM_ARITH_TBLS, cuchar]
    numScans: cint
    scanInfo: pointer
    rawDataIn, arithCode, optimizeCoding, cCIR601sampling: cint
    when after70:
      doFancyDownsampling: cint
    smoothingFactor: cint
    dctMethod: JpegDCTMethod
    restartInterval: cuint
    restartInRows, writeJFIFHeader: cint
    jfifMajorVersion, jfifMinorVersion, densityUnit: cuchar
    xDensity, yDensity: cushort
    writeAdobeMarker: cint
    nextScanline: cuint
    progressiveMode, maxHSampFactor, maxVSampFactor: cint
    when after70:
      minDCTHScaledSize, minDCTVScaledSize: cint
    totaliMCURows: cuint
    compsInScan: cint
    curCompInfo: array[MAX_COMPS_IN_SCAN, pointer]
    mCUsPerRow, mCURowsInScan: cuint
    blocksInMCU: cint
    MCU_membership: array[C_MAX_BLOCKS_IN_MCU, cint]
    ss, se, ah, al: cint
    when after80:
      blockSize: cint
      naturalOrder: ptr UncheckedArray[cint]
      limSe: cint
    master, main, prep, coef, marker, cconvert, downsample, fdct, entropy: pointer
    scriptSpace: pointer
    scriptSpaceSize: cint

  JpegDecompress = object
    err: ptr JpegErrorMgr
    mem, progress, clientData: pointer
    isDecompressor, globalInt: cint
    src: pointer
    imageWidth, imageHeight: cuint
    numComponents: cint
    jpegColorSpace, outColorSpace: JpegColorSpace
    scaleNum, scaleDenom: cuint
    outputGamma: cdouble
    bufferedImage, rawDataOut: cint
    dctMethod: JpegDCTMethod
    doFancyUpsampling, doBlockSmoothing, quantizeColors: cint
    ditherMode: JpegDitherMode
    twoPassQuantize, desiredNumberOfColors, enable1passQuant,
      enableExternalQuant, enable2passQuant: cint
    outputWidth, outputHeight: cuint
    outColorComponents, outputComponents, recOutbufHeight,
      actualNumberOfColors: cint
    colormap: pointer
    outputScanline: cuint
    inputScanNumber: cint
    inputIMCURow: cuint
    outputScanNumber: cint
    outputIMCURow: cuint
    coefBits: ptr array[DCTSIZE2, cint]
    quantTblPtrs: array[NUM_QUANT_TBLS, pointer]
    dcHuffTblPtrs: array[NUM_HUFF_TBLS, pointer]
    acHuffTblPtrs: array[NUM_HUFF_TBLS, pointer]
    dataPrecision: cint
    compInfo: ptr UncheckedArray[JpegComponentInfo]
    when after80:
      isBaseline: cint
    progressiveMode, arithCode: cint
    arithDcL: array[NUM_ARITH_TBLS, cuchar]
    arithDcU: array[NUM_ARITH_TBLS, cuchar]
    arithAcK: array[NUM_ARITH_TBLS, cuchar]
    restartInterval: cuint
    sawJFIFMarker: cint
    jFIFMajorVersion, jFIFMinorVersion, densityUnit: cuchar
    xDensity, yDensity: cushort
    writeAdobeMarker: cint
    adobeTransform: cuchar
    cCIR601Sampling: cint
    markerList: pointer
    maxHSampFactor, maxVSampFactor: cint
    when after70:
      minDCTHScaledSize, minDCTVScaledSize: cint
    else:
      minDCTScaledSize: cint
    totalIMCURows: cuint
    sampleRangeLimit: ptr UncheckedArray[cuchar]
    compsInScan: cint
    curCompInfo: array[MAX_COMPS_IN_SCAN, pointer]
    mCUsPerRow, mCURowsInScan: cuint
    blocksInMCU: cint
    mCUMembership: array[D_MAX_BLOCKS_IN_MCU, cint]
    ss, se, ah, al: cint
    when after80:
      blockSize: cint
      naturalOrder: ptr UncheckedArray[cint]
      limSe: cint
    unreadMarker: cint
    master, main, coef, post, inputctl, marker, entropy, idct, upsample,
      cconvert, cquantize: pointer

  MsgParm {.union.} = object
    i: array[8, cint]
    s: array[JMSG_STR_PARM_MAX, cchar]

  JpegErrorMgr = object
    errorExit: proc(cinfo: ptr JpegCommon) {.nimcall.}
    emitMessage: proc(cinfo: ptr JpegCommon, msg_level: cint) {.nimcall.}
    outputMessage: proc(cinfo: ptr JpegCommon) {.nimcall.}
    formatMessage: proc(cinfo: ptr JpegCommon, buffer: ptr cchar) {.nimcall.}
    resetErrorMgr: proc(cinfo: ptr JpegCommon) {.nimcall.}
    msgCode: cint
    msgParm: MsgParm
    traceLevel: cint
    numWarning: clong
    jpegMessageTable: ptr ptr cchar
    lastJpegMessage: cint
    addonMessageTable: ptr ptr cchar
    firstAddonMessage, lastAddonMessage: cint

  JpegDestinationMgr = object
    nextOutputByte: ptr cuchar
    freeInBuffer: csize_t
    initDestination: proc(cinfo: ptr JpegCompress) {.nimcall.}
    emptyOutputBuffer: proc(cinfo: ptr JpegCompress): cint {.nimcall.}
    termDestination: proc(cinfo: ptr JpegCompress) {.nimcall.}

  DestinationMgr[T] = object
    pub: JpegDestinationMgr
    buffer: ptr T

  JpegComponentInfo = object
    componentId, componentIndex, hSampFactor, vSampFactor, quantTblNo,
      dcTblNo, acTblNo: cint
    widthInBlocks, heightInBlocks: cuint
    when after70:
      dCTHScaledSize, dCTVScaleSize: cint
    else:
      dCTScaledSize: cint
    downsampledWidth, downsampledHeight: cuint
    componentNeeded, mCUWidth, mCUHeight, mCUBlocks, mCUSampleWidth,
      lastColWidth, lastRowHeight: cint
    quantTable, dctTable: pointer

  JSAMPROW = ptr UncheckedArray[cuchar]
  JSAMPARRAY = ptr UncheckedArray[JSAMPROW]

{.push importc, dynlib: libname, cdecl.}

proc jpeg_CreateCompress(cinfo: ptr JpegCompress, version: cint, size: csize_t)
proc jpeg_CreateDecompress(dinfo: ptr JpegDecompress, version: cint, size: csize_t)
proc jpeg_destroy_compress(cinfo: ptr JpegCompress)
proc jpeg_destroy_decompress(dinfo: ptr JpegDecompress)
proc jpeg_std_error(err: ptr JpegErrorMgr): ptr JpegErrorMgr
proc jpeg_stdio_dest(cinfo: ptr JpegCompress, outfile: File)
proc jpeg_stdio_src(dinfo: ptr JpegDecompress, infile: File)
when after80:
  proc jpeg_mem_src(dinfo: ptr JpegDecompress, inbuffer: ptr cuchar, insize: culong)
proc jpeg_read_header(dinfo: ptr JpegDecompress, require_image: cint): cint
proc jpeg_start_decompress(dinfo: ptr JpegDecompress): cint
proc jpeg_read_scanlines(dinfo: ptr JpegDecompress, scanlines: JSAMPARRAY,
  max_lines: cuint): cuint
proc jpeg_finish_decompress(dinfo: ptr JpegDecompress): cint
proc jpeg_set_defaults(cinfo: ptr JpegCompress)
proc jpeg_set_quality(cinfo: ptr JpegCompress, quality, force_baseline: cint)
proc jpeg_start_compress(cinfo: ptr JpegCompress, write_all_tables: cint): cint
proc jpeg_write_scanlines(cinfo: ptr JpegCompress, scanlines: JSAMPARRAY,
  num_lines: cuint): cuint
proc jpeg_finish_compress(cinfo: ptr JpegCompress): cint

{.pop.}

proc errorHandler(cinfo: ptr JpegCommon) =
  let err = cast[ptr JpegErrorMgr](cinfo.err)
  var buffer: array[JMSG_LENGTH_MAX, cchar]
  err.formatMessage cinfo, addr buffer[0]
  raise newException(IOError, $(cast[cstring](addr buffer)))

proc discardOutput(cinfo: ptr JpegCommon) = discard

proc newDecompressor(err: var JpegErrorMgr): JpegDecompress =
  result.err = jpeg_std_error(addr err)
  err.errorExit = errorHandler
  err.outputMessage = discardOutput
  jpeg_CreateDecompress addr result, JPEG_LIB_VERSION, csize_t sizeof JpegDecompress

template readJPEGImpl(source: typed, dctMethod: JpegDCTMethod,
  fancyUpsampling, blockSmoothing: bool): untyped =
  var
    err: JpegErrorMgr
    dinfo = newDecompressor(err)
    dinfop = addr dinfo
  defer: jpeg_destroy_decompress dinfop

  when source is File:
    jpeg_stdio_src dinfop, source
  elif source is openArray[char]:
    jpeg_mem_src dinfop, cast[ptr cuchar](unsafeAddr source[0]), source.len.culong

  discard jpeg_read_header(dinfop, 1)

  dinfo.dctMethod = dctMethod
  dinfo.doFancyUpsampling = fancyUpsampling.cint
  dinfo.doBlockSmoothing = blockSmoothing.cint

  discard jpeg_start_decompress dinfop

  var
    r = initImage[ColorRGBU](dinfo.outputWidth, dinfo.outputHeight)
    rows = newSeq[ptr UncheckedArray[cuchar]](r.height)
    address = cast[int](addr r[0])
  let rowWidth = r.width * sizeof r.colorType

  for row in 0..rows.high:
    rows[row] = cast[ptr UncheckedArray[cuchar]](address)
    address += rowWidth

  var scanline = dinfo.outputScanline.int
  while scanline < rows.len:
    discard jpeg_read_scanlines(dinfop,
      cast[JSAMPARRAY](addr rows[scanline]), (rows.len - scanline).cuint)
    scanline = dinfo.outputScanline.int

  discard jpeg_finish_decompress dinfop

  when T is ColorRGBU:
    result = r
  else:
    result = r.converted(T)

proc readJPEG*[T: Color](file: File, dctMethod = jDCTmISlow,
  fancyUpsampling = false, blockSmoothing = true): Image[T] =
  readJPEGImpl file, dctMethod, fancyUpsampling, blockSmoothing

proc readJPEG*[T: Color](data: openArray[char], dctMethod = jDCTmISlow,
  fancyUpsampling = false, blockSmoothing = true): Image[T] =
  readJPEGImpl data, dctMethod, fancyUpsampling, blockSmoothing

proc loadJPEG*[T: Color](path: string, dctMethod = jDCTmISlow,
  fancyUpsampling = false, blockSmoothing = true): Image[T] =
  let file = open(path, fmRead)
  defer: close file
  result = readJPEG[T](file, dctMethod, fancyUpsampling, blockSmoothing)

proc newCompressor(err: var JpegErrorMgr): JpegCompress =
  result.err = jpeg_std_error(addr err)
  err.errorExit = errorHandler
  err.outputMessage = discardOutput
  jpeg_CreateCompress addr result, JPEG_LIB_VERSION, csize_t sizeof JpegCompress

proc initDestination[T](cinfo: ptr JpegCompress) =
  let a = cast[ptr DestinationMgr[T]](cinfo.dest)
  a.buffer[].setLen(65536)
  a.pub.nextOutputByte = addr a.buffer[0]
  a.pub.freeInBuffer = a.buffer[].len.csize_t

proc emptyOutputBuffer[T](cinfo: ptr JpegCompress): cint =
  let
    a = cast[ptr DestinationMgr[T]](cinfo.dest)
    size = a.buffer[].len
  a.buffer[].setLen(size * 2)
  a.pub.nextOutputByte = addr a.buffer[][size]
  a.pub.freeInBuffer = size.csize_t
  result = 1

proc termDestination[T](cinfo: ptr JpegCompress) =
  let a = cast[ptr DestinationMgr[T]](cinfo.dest)
  a.buffer[].setLen(a.buffer[].len - a.pub.freeInBuffer.int)

proc newDestinationMgr[T](buf: ptr T): DestinationMgr[T] =
  result.buffer = buf
  result.pub.initDestination = initDestination[T]
  result.pub.emptyOutputBuffer = emptyOutputBuffer[T]
  result.pub.termDestination = termDestination[T]

template writeJPEGImpl[T: Color](img: Image[T], dst: typed, quality: int,
  optimizeCoding: bool): untyped =
  var
    err: JpegErrorMgr
    cinfo = newCompressor(err)
  let cinfop = addr cinfo
  defer: jpeg_destroy_compress cinfop

  when dst is File:
    jpeg_stdio_dest cinfop, dst
  when dst is string:
    var destMgr = newDestinationMgr(addr dst)
    cinfo.dest = cast[ptr JpegDestinationMgr](addr destMgr)

  let i = img.converted(ColorRGBU)

  cinfo.imageWidth = i.width.cuint
  cinfo.imageHeight = i.height.cuint
  cinfo.inputComponents = 3
  cinfo.inColorSpace = jcsRGB

  jpeg_set_defaults cinfop
  jpeg_set_quality cinfop, quality.cint, 0
  cinfo.optimizeCoding = optimizeCoding.cint
  cinfo.dctMethod = dctMethod

  discard jpeg_start_compress(cinfop, 1)

  var
    rows = newSeq[ptr UncheckedArray[cuchar]](i.height)
    address = cast[int](unsafeAddr i[0])
  let rowWidth = i.width * sizeof i.colorType

  for row in 0..rows.high:
    rows[row] = cast[ptr UncheckedArray[cuchar]](address)
    address += rowWidth

  var scanline = cinfo.nextScanline.int
  while scanline < rows.len:
    discard jpeg_write_scanlines(cinfop,
      cast[JSAMPARRAY](unsafeAddr rows[scanline]), (rows.len - scanline).cuint)
    scanline = cinfo.nextScanline.int

  discard jpeg_finish_compress cinfop

proc writeJPEG*[T: Color](i: Image[T], file: File, quality: range[0..100] = 75,
  optimizeCoding = false, dctMethod = jDCTmISlow) =
  i.writeJPEGImpl file, quality, optimizeCoding

proc writeJPEG*[T: Color](i: Image[T], quality: range[0..100] = 75,
  optimizeCoding = false, dctMethod = jDCTmISlow): string =
  i.writeJPEGImpl result, quality, optimizeCoding

proc saveJPEG*[T: Color](i: Image[T], path: string, quality: range[0..100] = 75,
  optimizeCoding = false, dctMethod = jDCTmISlow) =
  let file = open(path, fmWrite)
  defer: close file
  i.writeJPEG file, quality, optimizeCoding
