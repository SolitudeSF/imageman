import ../colors

type
  Image*[T: Color] = object
    ## Image object. `data` field is a sequence of pixels stored in arrays.
    width*, height*: int
    data*: seq[T]
