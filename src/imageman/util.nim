import macros

proc replaceNodes(ast: NimNode): NimNode =
  ## Replace NimIdent and NimSym by a fresh ident node
  proc inspect(node: NimNode): NimNode =
    case node.kind:
    of {nnkIdent, nnkSym}:
      return ident($node)
    of nnkEmpty:
      return node
    of nnkLiterals:
      return node
    else:
      var rTree = node.kind.newTree()
      for child in node:
        rTree.add inspect(child)
      return rTree
  result = inspect(ast)

proc replaceNodes(ast, what, by: NimNode): NimNode =
  ## Replace "what" ident node by "by"
  proc inspect(node: NimNode): NimNode =
    case node.kind:
    of {nnkIdent, nnkSym}:
      if node.eqIdent(what):
        return by
      return node
    of nnkEmpty:
      return node
    of nnkLiterals:
      return node
    else:
      var rTree = node.kind.newTree()
      for child in node:
        rTree.add inspect(child)
      return rTree
  result = inspect(ast)

macro genMutating*(p: typed, name: untyped, doc: static[string] = ""): untyped =
  ## Macro for generating mutating version of non-mutating procedure.
  result = p.getImpl
  assert result.kind in {nnkFuncDef, nnkProcDef}

  var call = nnkCall.newTree(result[0].strVal.ident)
  for i in 1..<result[3].len:
    for j in 0..result[3][i].len - 3:
      let c = result[3][i][j]
      if c.kind == nnkIdent: call.add c
      elif c.kind == nnkSym: call.add c.strVal.ident

  result[0] = nnkPostfix.newTree(ident "*", ident name.strVal)
  result[2] = result[5][1]
  result[3][0] = newEmptyNode()
  result[3][1][1] = nnkVarTy.newTree(result[3][1][1])
  result[4] = nnkPragma.newTree newIdentNode "inline"
  result[5] = newEmptyNode()

  var body = nnkStmtList.newTree()

  if doc.len > 0:
    body.add doc.newCommentStmtNode
  elif result[6][0].kind == nnkCommentStmt:
    body.add result[6][0]

  body.add nnkAsgn.newTree(result[3][1][0], call)

  result[6] = body

  result = replaceNodes(result)

macro genNonMutating*(p: typed, name: untyped, doc: static[string] = "") =
  ## Macro for generating non-mutating version of mutating procedure.
  result = p.getImpl
  assert result.kind in {nnkFuncDef, nnkProcDef}

  var call = nnkCall.newTree(result[0].strVal.ident, ident "result")
  for i in 2..<result[3].len:
    for c in result[3][i]:
      if c.kind == nnkIdent: call.add c

  result[0] = nnkPostfix.newTree(ident "*", ident name.strVal)
  result[2] = result[5][1]
  result[3][1][1] = result[3][1][1][0]
  result[3][0] = result[3][1][1]
  result[4] = nnkPragma.newTree newIdentNode "inline"
  result[5] = newEmptyNode()

  var body = nnkStmtList.newTree()

  if doc.len > 0:
    body.add doc.newCommentStmtNode
  elif result[6][0].kind == nnkCommentStmt:
    body.add result[6][0]

  body.add nnkAsgn.newTree(ident "result", result[3][1][0]), call

  result[6] = body

  result = replaceNodes(result)

template copy*[T1, T2](dst: var openArray[T1], src: openArray[T2], count: Natural, body): untyped =
  when nimvm:
    for i in 0..<count:
      let it {.inject.} = src[i]
      dst[i] = body
  else:
    copyMem addr dst[0], unsafeAddr src[0], count * sizeof T1

macro staticFor*(idx: untyped{nkIdent}, start, stopEx: static int, body: untyped): untyped =
  result = newStmtList()
  for i in start ..< stopEx:
    result.add nnkBlockStmt.newTree(
      ident("unrolledIter_" & $idx & $i),
      body.replaceNodes(idx, newLit i)
    )
