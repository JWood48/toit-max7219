

rotate arr/ByteArray -> ByteArray:
  if arr.size != 8:
    print "BAD ARGUMENT!!"
    throw "array size must be 8"
  out := #[0, 0, 0, 0, 0, 0, 0, 0]
  for i := 0; i < 8; i++:
    for j := 0; j < 8; j++:
      val := arr[i] >> j & 1
      out[7-j] |= val << i
  return out
